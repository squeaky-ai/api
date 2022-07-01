# frozen_string_literal: true

module Resolvers
  module Analytics
    class SessionDurations < Resolvers::Base
      type Types::Analytics::SessionDurations, null: false

      def resolve_with_timings
        current_average = get_average_duration(object.from_date, object.to_date)
        trend_date_range = Trend.offset_period(object.from_date, object.to_date)
        previous_average = get_average_duration( *trend_date_range)

        {
          average: current_average,
          trend: current_average - previous_average
        }
      end

      private

      def get_average_duration(from_date, to_date)
        sql = <<-SQL
          SELECT AVG(disconnected_at - connected_at) as duration
          FROM recordings
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
        SQL

        variables = [
          object.site.id,
          from_date,
          to_date,
          [Recording::ACTIVE, Recording::DELETED]
        ]

        result = Sql.execute(sql, variables)
        result.first['duration'] || 0
      end
    end
  end
end
