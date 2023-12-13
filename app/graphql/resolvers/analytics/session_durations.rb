# frozen_string_literal: true

module Resolvers
  module Analytics
    class SessionDurations < Resolvers::Base
      type Types::Analytics::SessionDurations, null: false

      def resolve
        current_average = get_average_duration(object.range.from, object.range.to)
        previous_average = get_average_duration(object.range.trend_from, object.range.trend_to)

        {
          average: current_average,
          trend: current_average - previous_average
        }
      end

      private

      def get_average_duration(from_date, to_date)
        sql = <<-SQL.squish
          SELECT
            AVG(activity_duration) as duration
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            toDate(disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
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
