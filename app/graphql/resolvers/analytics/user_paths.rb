# frozen_string_literal: true

module Resolvers
  module Analytics
    class UserPaths < Resolvers::Base
      type [Types::Analytics::UserPath, { null: false }], null: false

      argument :page, String, required: true
      argument :position, Types::Analytics::PathPosition, required: true

      def resolve_with_timings(page:, position:)
        sql = <<-SQL
          SELECT
            groupArray(url) urls
          FROM (
            SELECT
              recording_id,
              url
            FROM
              page_events
            WHERE
              site_id = ? AND
              toDate(exited_at / 1000) BETWEEN ? AND ?
            ORDER BY
              exited_at ASC
          )
          GROUP BY
            recording_id
          HAVING
            has(urls, ?)
        SQL

        variables = [
          object.site.id,
          object.range.from,
          object.range.to,
          page
        ]

        format_results(
          Sql::ClickHouse.select_all(sql, variables),
          page,
          position
        )
      end

      private

      def format_results(results, page, position)
        results.map do |result|
          pages_list = result['urls']

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
