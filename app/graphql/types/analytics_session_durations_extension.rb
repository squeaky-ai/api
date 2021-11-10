# frozen_string_literal: true

module Types
  # How long people spend on site
  class AnalyticsSessionDurationsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      current_average = get_average_duration(site_id, from_date, to_date)
      trend_date_range = offset_dates_by_period(from_date, to_date)
      previous_average = get_average_duration(site_id, *trend_date_range)

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
        WHERE site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?;
      SQL

      result = Sql.execute(sql, [site_id, from_date, to_date])
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
