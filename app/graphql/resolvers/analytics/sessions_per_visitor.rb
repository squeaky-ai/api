# frozen_string_literal: true

module Resolvers
  module Analytics
    class SessionsPerVisitor < Resolvers::Base
      type Types::Analytics::SessionsPerVisitor, null: false

      def resolve_with_timings
        current_average = get_average_count(object[:site_id], object[:from_date], object[:to_date])
        trend_date_range = Trend.offset_period(object[:from_date], object[:to_date])
        previous_average = get_average_count(object[:site_id], *trend_date_range)

        {
          average: current_average,
          trend: current_average - previous_average
        }
      end

      private

      def get_average_count(site_id, from_date, to_date)
        sql = <<-SQL
          SELECT visitor_id, COUNT(visitor_id)
          FROM recordings
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
          GROUP BY visitor_id
        SQL

        variables = [
          site_id,
          from_date,
          to_date,
          [Recording::ACTIVE, Recording::DELETED]
        ]

        results = Sql.execute(sql, variables)

        Maths.average(results.map { |c| c['count'] })
      end
    end
  end
end
