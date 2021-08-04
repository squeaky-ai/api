# frozen_string_literal: true

module Types
  # The list of the most popular browsers and their counts
  class AnalyticsBrowserExtension < AnalyticsExtension
    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:site_id]
      from_date = arguments[:from_date]
      to_date = arguments[:to_date]

      sql = <<-SQL
        SELECT DISTINCT(useragent), count(*)
        FROM recordings
        WHERE site_id = ? AND created_at::date BETWEEN ? AND ?
        GROUP BY useragent;
      SQL

      result = execute_sql(sql, [site_id, from_date, to_date])
      map_results(result)
    end

    private

    def map_results(result)
      out = {}

      result.each do |r|
        browser = UserAgent.parse(r[0]).browser
        out[browser] ||= 0
        out[browser] += r[1]
      end

      out.map { |k, v| { name: k, count: v } }
    end
  end
end
