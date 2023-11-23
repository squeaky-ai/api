# frozen_string_literal: true

module Resolvers
  module Analytics
    class SessionsPerVisitor < Resolvers::Base
      type Types::Analytics::SessionsPerVisitor, null: false

      def resolve_with_timings
        current_average = get_average_count(object.range.from, object.range.to)
        previous_average = get_average_count(object.range.trend_from, object.range.trend_to)

        {
          average: current_average,
          trend: current_average - previous_average
        }
      end

      private

      def get_average_count(from_date, to_date)
        sql = <<-SQL.squish
          SELECT
            AVG(count)
          FROM (
            SELECT
              visitor_id,
              COUNT(visitor_id) count
            FROM
              recordings
            WHERE
              site_id = :site_id AND
              toDate(recordings.disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
            GROUP BY
              visitor_id
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
