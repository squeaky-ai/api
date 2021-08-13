# frozen_string_literal: true

module Types
  # Analytics data
  class AnalyticsLanguageExtension < AnalyticsQuery
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT DISTINCT LOWER(locale), COUNT(*) locale_count
        FROM recordings
        WHERE site_id = ? AND created_at::date BETWEEN ? AND ?
        GROUP BY LOWER(locale)
        ORDER BY locale_count DESC
        LIMIT 6;
      SQL

      result = execute_sql(sql, [site_id, from_date, to_date])
      map_results(result)
    end

    private

    def map_results(result)
      result.map do |r|
        {
          name: Locale.get_language(r[0]),
          count: r[1]
        }
      end
    end
  end
end
