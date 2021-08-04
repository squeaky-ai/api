# frozen_string_literal: true

module Types
  # Analytics data
  class AnalyticsLanguageExtension < AnalyticsExtension
    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:site_id]
      from_date = arguments[:from_date]
      to_date = arguments[:to_date]

      sql = <<-SQL
        SELECT DISTINCT(locale), COUNT(*) locale_count
        FROM recordings
        WHERE site_id = ? AND created_at::date BETWEEN ? AND ?
        GROUP BY locale
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
