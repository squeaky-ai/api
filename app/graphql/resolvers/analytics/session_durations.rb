# frozen_string_literal: true

module Resolvers
  module Analytics
    class SessionDurations < Resolvers::Base
      type Types::Analytics::SessionDurations, null: false

      def resolve
        current_average = get_average_duration(object[:site_id], object[:from_date], object[:to_date])
        trend_date_range = offset_dates_by_period(object[:from_date], object[:to_date])
        previous_average = get_average_duration(object[:site_id], *trend_date_range)

        {
          average: current_average,
          trend: current_average - previous_average
        }
      end

      private

      def get_average_duration(site_id, from_date, to_date)
        sql = <<-SQL
          SELECT AVG(disconnected_at - connected_at) as duration
          FROM recordings
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
        SQL

        variables = [
          site_id,
          from_date,
          to_date,
          [Recording::ACTIVE, Recording::DELETED]
        ]

        result = Sql.execute(sql, variables)
        result.first['duration'] || 0
      end

      def parse_date(date)
        Date.strptime(date, '%Y-%m-%d')
      end

      def offset_dates_by_period(from_date, to_date)
        from = parse_date(from_date)
        to = parse_date(to_date)

        # Same day is pointless because you're comparing it against
        # itself, so always do at least one day
        diff = (to - from).days < 1.day ? 1.day : (to - from)

        [from - diff, to - diff]
      end
    end
  end
end
