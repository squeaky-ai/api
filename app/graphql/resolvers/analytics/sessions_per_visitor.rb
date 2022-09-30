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
        # TODO: Replace with ClickHouse
        sql = <<-SQL
          SELECT visitor_id, COUNT(visitor_id)
          FROM recordings
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
          GROUP BY visitor_id
        SQL

        variables = [
          object.site.id,
          from_date,
          to_date
        ]

        results = Sql.execute(sql, variables)

        Maths.average(results.map { |c| c['count'] })
      end
    end
  end
end
