# frozen_string_literal: true

module Types
  # The total number of visitors
  class AnalyticsVisitorsCountExtension < AnalyticsQuery
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT COUNT(DISTINCT(visitors.visitor_id)),
               COUNT(DISTINCT CASE recordings.viewed WHEN TRUE THEN NULL ELSE visitors.visitor_id END)
        FROM visitors
        INNER JOIN recordings on recordings.visitor_id = visitors.id
        WHERE recordings.site_id = ? AND recordings.created_at::date BETWEEN ? AND ?;
      SQL

      result = execute_sql(sql, [site_id, from_date, to_date])[0]

      {
        total: result[0].to_i,
        new: result[1].to_i
      }
    end
  end
end
