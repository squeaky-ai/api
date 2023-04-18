# frozen_string_literal: true

module Resolvers
  module Analytics
    class Exits < Resolvers::Base
      type [Types::Analytics::Exit, { null: false }], null: false

      argument :size, Integer, required: false, default_value: 5

      def resolve_with_timings(size:)
        sql = <<-SQL
          SELECT
            x.url url,
            COALESCE((NULLIF(exit_rate_count, 0) / view_count) * 100, 0) percentage
          FROM (
            SELECT
              url,
              COUNT(*) view_count,
              COUNT(exited_on) FILTER(WHERE exited_on = true) exit_rate_count
            FROM
              page_events
            WHERE
              site_id = :site_id AND
              toDate(exited_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
            GROUP BY
              url
          ) x
          ORDER BY
            percentage DESC
          LIMIT :limit
        SQL

        variables = {
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to,
          limit: size
        }

        Sql::ClickHouse.select_all(sql, variables)
      end
    end
  end
end
