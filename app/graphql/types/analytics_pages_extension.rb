# frozen_string_literal: true

module Types
  # The list of the most viewed pages
  class AnalyticsPagesExtension < AnalyticsQuery
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT p.page_view, count(*) page_view_count
        FROM recordings r
        cross join lateral unnest(r.page_views) p(page_view)
        WHERE r.site_id = ? AND created_at::date BETWEEN ? AND ?
        group by p.page_view
        order by page_view_count desc;
      SQL

      result = execute_sql(sql, [site_id, from_date, to_date])
      map_results(result)
    end

    private

    def map_results(result)
      result.map do |r|
        {
          path: r[0],
          count: r[1]
        }
      end
    end
  end
end
