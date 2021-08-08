# frozen_string_literal: true

module Types
  # The data for the big graph
  class AnalyticsPageViewsRangeExtension < AnalyticsExtension
    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:site_id]
      from_date = arguments[:from_date]
      to_date = arguments[:to_date]

      sql = <<-SQL
        SELECT created_at, page_views
        FROM recordings
        WHERE site_id = ? AND created_at::date BETWEEN ? AND ?
        ORDER BY created_at;
      SQL

      result = execute_sql(sql, [site_id, from_date, to_date])
      map_results(result)
    end

    private

    def map_results(result)
      result.map do |r|
        {
          date: r[0].to_time.iso8601,
          page_view_count: r[1].gsub(/[{}]/, '').split(',').size
        }
      end
    end
  end
end
