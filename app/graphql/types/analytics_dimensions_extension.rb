# frozen_string_literal: true

module Types
  # The min, max and avg screen dimensions
  class AnalyticsDimensionsExtension < AnalyticsQuery
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT MAX(viewport_x), MIN(viewport_x), AVG(viewport_x)
        FROM recordings
        WHERE site_id = ? AND created_at::date BETWEEN ? AND ?;
      SQL

      result = execute_sql(sql, [site_id, from_date, to_date])
      map_results(result)
    end

    private

    def map_results(result)
      {
        max: result[0][0] || 0,
        min: result[0][1] || 0,
        avg: result[0][2] || 0
      }
    end
  end
end
