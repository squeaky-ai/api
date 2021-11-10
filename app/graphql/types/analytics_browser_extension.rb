# frozen_string_literal: true

module Types
  # The list of the most popular browsers and their counts
  class AnalyticsBrowserExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT DISTINCT(useragent) useragent, count(*) useragent_count
        FROM recordings
        WHERE site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?
        GROUP BY useragent
        ORDER BY useragent_count
      SQL

      results = Sql.execute(sql, [site_id, from_date, to_date])

      out = {}

      results.each do |result|
        browser = UserAgent.parse(result['useragent']).browser
        out[browser] ||= 0
        out[browser] += result['useragent_count']
      end

      out.map { |k, v| { name: k, count: v } }
    end
  end
end
