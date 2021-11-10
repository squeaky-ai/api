# frozen_string_literal: true

module Types
  # The list of the most viewed pages
  class AnalyticsPagesExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT url, count(url) page_count, AVG(exited_at - entered_at) page_avg
        FROM pages
        INNER JOIN recordings ON recordings.id = pages.recording_id
        WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
        GROUP BY pages.url
      SQL

      results = Sql.execute(sql, [site_id, from_date, to_date])

      results.map do |page|
        {
          path: page['url'],
          count: page['page_count'],
          avg: page['page_avg'].negative? ? 0 : page['page_avg']
        }
      end
    end
  end
end
