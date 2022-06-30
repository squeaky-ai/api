# frozen_string_literal: true

module Resolvers
  module Analytics
    class UserPaths < Resolvers::Base
      type [Types::Analytics::UserPath, { null: true }], null: false

      argument :page, String, required: true
      argument :position, Types::Analytics::PathPosition, required: true

      def resolve_with_timings(page:, position:)
        # TODO: Can we drop recordings?
        sql = <<-SQL
          SELECT page_urls path
          FROM (
            SELECT
              ARRAY_AGG(pages.url ORDER BY entered_at ASC) page_urls
            FROM
              recordings
            INNER JOIN
              pages ON pages.recording_id = recordings.id
            WHERE
              recordings.site_id = ? AND
              to_timestamp(pages.entered_at / 1000)::date BETWEEN ? AND ? AND
              recordings.status IN (?)
            GROUP BY
              pages.recording_id
          ) page_urls
          WHERE page_urls @> ?
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED],
          "{#{page}}"
        ]

        format_results(
          Sql.execute(sql, variables),
          page,
          position
        )
      end

      private

      def format_results(paths, page, position)
        paths.map do |path|
          # The postgres array does not get converted to a ruby array
          pages_list = path['path'].sub('{', '').sub('}', '').split(',')

          if position == 'Start'
            # Find the first occurance of the page in the array
            pages_index = pages_list.index(page)
            # Return every page from the first occurance of the
            # selected page until the end
            { path: pages_list.slice(pages_index, pages_list.size) }
          else
            # Find the last occurance of the page in the array
            pages_index = pages_list.rindex(page)
            # Return every page leading up to the point where
            # the last instance of the select page exists
            { path: pages_list.slice(0, pages_index + 1) }
          end
        end
      end
    end
  end
end
