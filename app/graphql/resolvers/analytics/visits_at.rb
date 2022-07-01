# frozen_string_literal: true

module Resolvers
  module Analytics
    class VisitsAt < Resolvers::Base
      type [Types::Analytics::VisitAt, { null: true }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT to_char(to_timestamp(disconnected_at / 1000), 'Dy,HH24') day_hour, COUNT(*)
          FROM recordings
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
          GROUP BY day_hour;
        SQL

        variables = [
          object.site.id,
          object.from_date,
          object.to_date,
          [Recording::ACTIVE, Recording::DELETED]
        ]

        results = Sql.execute(sql, variables)

        results.map do |r|
          day, hour = r['day_hour'].split(',')

          {
            day: day.strip,
            hour: hour.to_i,
            count: r['count']
          }
        end
      end
    end
  end
end
