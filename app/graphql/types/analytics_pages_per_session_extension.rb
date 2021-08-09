# frozen_string_literal: true

module Types
  # The number of pages viewed per session
  class AnalyticsPagesPerSessionExtension < AnalyticsQuery
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT AVG( array_length(page_views, 1) )
        FROM recordings
        WHERE site_id = ? AND created_at::date BETWEEN ? AND ?;
      SQL

      execute_sql(sql, [site_id, from_date, to_date])[0][0].to_f
    end
  end
end
