# frozen_string_literal: true

module Resolvers
  module Analytics
    class PagesPerSession < Resolvers::Base
      type Types::AnalyticsPagesPerSession, null: false

      def resolve
        current_average = get_average_count(object.site_id, object.from_date, object.to_date)
        trend_date_range = offset_dates_by_period(object.from_date, object.to_date)
        previous_average = get_average_count(object.site_id, *trend_date_range)

        {
          average: current_average,
          trend: current_average - previous_average
        }
      end

      def get_average_count(site_id, from_date, to_date)
        sql = <<-SQL
          SELECT count(pages.id)
          FROM recordings
          INNER JOIN pages ON pages.recording_id = recordings.id
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
          GROUP BY recordings.id
        SQL

        results = Sql.execute(sql, [site_id, from_date, to_date])

        values = results.map { |r| r['count'] }

        return 0 if values.empty?

        values.sum.fdiv(values.size)
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
