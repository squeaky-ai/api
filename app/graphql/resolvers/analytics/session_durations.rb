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
        # TODO: Replace with ClickHouse
        sql = <<-SQL
          SELECT AVG(disconnected_at - connected_at) as duration
          FROM recordings
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
        SQL

        variables = [
          object.site.id,
          from_date,
          to_date
        ]

        result = Sql.execute(sql, variables)
        result.first['duration'] || 0
      end
    end
  end
end
