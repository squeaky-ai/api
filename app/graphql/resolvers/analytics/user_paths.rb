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
            groupArray(url) path
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
            path[?] = ?
        SQL

        variables = [
          object.site.id,
          object.range.from,
          object.range.to,
          position == 'Start' ? 1 : -1,
          page
        ]

        Sql::ClickHouse.select_all(sql, variables)
      end
    end
  end
end
