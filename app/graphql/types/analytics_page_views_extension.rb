# frozen_string_literal: true

module Types
  # The total number of page views
  class AnalyticsPageViewsExtension < AnalyticsExtension
    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:site_id]
      from_date = arguments[:from_date]
      to_date = arguments[:to_date]

      sql = <<-SQL
        SELECT SUM( array_length(page_views, 1) )
        FROM recordings
        WHERE site_id = ? AND created_at::date BETWEEN ? AND ?;
      SQL

      execute_sql(sql, [site_id, from_date, to_date])[0][0].to_i
    end
  end
end
