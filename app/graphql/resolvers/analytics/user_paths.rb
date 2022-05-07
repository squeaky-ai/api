# frozen_string_literal: true

module Resolvers
  module Analytics
    class UserPaths < Resolvers::Base
      type [Types::Analytics::UserPath, { null: true }], null: false

      argument :start_page, String, required: false, default_value: nil
      argument :end_page, String, required: false, default_value: nil

      def resolve(start_page:, end_page:)
        return [] unless start_page || end_page

        sql = <<-SQL
          SELECT page_urls path
          FROM (
            SELECT
              ARRAY_AGG(pages.url ORDER BY entered_at DESC) page_urls
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
          WHERE #{page_where_clause(start_page, end_page)} AND array_length(page_urls, 1) != 1
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED]
        ]

        variables.push(start_page) if start_page
        variables.push(end_page) if end_page

        Sql.execute(sql, variables).map do |path|
          {
            path: path['path'].sub('{', '').sub('}', '').split(',')
          }
        end
      end

      private

      def page_where_clause(start_page, end_page)
        return 'page_urls[1] = ? AND page_urls[array_upper(page_urls, 1)] = ?' if start_page && end_page
        return 'page_urls[1] = ?' if start_page
        return 'page_urls[array_upper(page_urls, 1)] = ?' if end_page

        ''
      end
    end
  end
end
