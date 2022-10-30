# frozen_string_literal: true

module Resolvers
  module Analytics
    class SessionDurations < Resolvers::Base
      type Types::Analytics::SessionDurations, null: false

      def resolve_with_timings
        current_average = get_average_duration(object.range.from, object.range.to)
        previous_average = get_average_duration(object.range.trend_from, object.range.trend_to)

        {
          average: current_average,
          trend: current_average - previous_average
        }
      end

      private

      def get_average_duration(from_date, to_date)
        sql = <<-SQL
          SELECT
            AVG(disconnected_at - connected_at) as duration
          FROM
            recordings
          WHERE
            site_id = ? AND
            toDate(disconnected_at / 1000)::date BETWEEN ? AND ?
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
