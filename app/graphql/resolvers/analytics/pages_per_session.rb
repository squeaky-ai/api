# frozen_string_literal: true

module Resolvers
  module Analytics
    class PagesPerSession < Resolvers::Base
      type Types::Analytics::PagesPerSession, null: false

      def resolve_with_timings
        current_average = get_average_count(object.range.from, object.range.to)
        previous_average = get_average_count(object.range.trend_from, object.range.trend_to)

        {
          average: current_average,
          trend: current_average - previous_average
        }
      end

      def get_average_count(from_date, to_date)
        sql = <<-SQL
          SELECT
            AVG(count)
          FROM (
            SELECT
              COUNT(*) count
            FROM
              page_events
            WHERE
              site_id = ? AND
              toDate(exited_at / 1000)::date BETWEEN ? AND ?
            GROUP BY
              recording_id
          )
        SQL

        variables = [
          object.site.id,
          from_date,
          to_date
        ]

        Sql::ClickHouse.select_value(sql, variables) || 0
      end
    end
  end
end
