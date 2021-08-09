# frozen_string_literal: true

module Types
  # How long people spend on site
  class AnalyticsAverageSessionDurationExtension < AnalyticsQuery
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT AVG( (disconnected_at - connected_at) ) as DURATION
        FROM recordings
        WHERE site_id = ? AND created_at::date BETWEEN ? AND ?;
      SQL

      execute_sql(sql, [site_id, from_date, to_date])[0][0].to_i
    end
  end
end
