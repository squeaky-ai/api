# frozen_string_literal: true

module Resolvers
  module Analytics
    class UserPaths < Resolvers::Base
      type [Types::Analytics::UserPath, { null: true }], null: false

      argument :page, String, required: true
      argument :position, Types::Analytics::PathPosition, required: true

      def resolve(page:, position:)
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
          WHERE #{page_where_clause(position)}
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED],
          page
        ]

        Sql.execute(sql, variables).map do |path|
          {
            path: path['path'].sub('{', '').sub('}', '').split(',')
          }
        end
      end

      private

      def page_where_clause(position)
        case position
        when 'Start'
          'page_urls[1] = ?'
        when 'End'
          'page_urls[array_upper(page_urls, 1)] = ?'
        end
      end
    end
  end
end
