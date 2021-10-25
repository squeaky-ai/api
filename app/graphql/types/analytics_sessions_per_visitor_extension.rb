# frozen_string_literal: true

module Types
  # The average number of sessions per visitor
  class AnalyticsSessionsPerVisitorExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      current_average = get_average_count(site_id, from_date, to_date)
      trend_date_range = offset_dates_by_period(from_date, to_date)
      previous_average = get_average_count(site_id, *trend_date_range)

      {
        average: current_average,
        trend: current_average - previous_average
      }
    end

    private

    def get_average_count(site_id, from_date, to_date)
      counts = Site
               .find(site_id)
               .recordings
               .select('visitor_id')
               .where('to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)
               .group(:visitor_id)
               .count(:visitor_id)

      values = counts.values

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
      diff = (to - from) || 1

      [from - diff, to - diff]
    end
  end
end
