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
        sql = <<-SQL.squish
          SELECT
            AVG(count)
          FROM (
            SELECT
              COUNT(*) count
            FROM
              page_events
            WHERE
              site_id = :site_id AND
              toDate(exited_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
            GROUP BY
              recording_id
          )
        SQL

        variables = {
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date:,
          to_date:
        }

        Sql::ClickHouse.select_value(sql, variables) || 0
      end
    end
  end
end
