# frozen_string_literal: true

module Types
  # The data for the big graph
  class AnalyticsViewsAndVisitorsPerHourExtension < AnalyticsExtension
    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:site_id]
      from_date = arguments[:from_date]
      to_date = arguments[:to_date]

      sql = <<-SQL
        SELECT SUM(array_length(page_views, 1)) page_views, count(DISTINCT viewer_id) visitors, date_trunc('hour', created_at) per_hour
        FROM recordings
        WHERE site_id = ? AND created_at::date BETWEEN ? AND ?
        GROUP BY per_hour
        ORDER BY per_hour;
      SQL

      result = execute_sql(sql, [site_id, from_date, to_date])
      map_views_and_visitors(result)
    end

    private

    def map_views_and_visitors(result)
      (0..24).to_a.map do |hour|
        match = result.find { |r| r[2].hour == hour }
        {
          hour: hour,
          page_views: match ? match[0] : 0,
          visitors: match ? match[1] : 0
        }
      end
    end
  end
end
