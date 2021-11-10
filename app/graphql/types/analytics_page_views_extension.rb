# frozen_string_literal: true

module Types
  # The list of visitors in a date range
  class AnalyticsPageViewsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT array_agg(pages.url) urls, max(pages.exited_at) exited_at
        FROM pages
        INNER JOIN recordings ON recordings.id = pages.recording_id
        WHERE site_id = ? AND to_timestamp(pages.exited_at / 1000)::date BETWEEN ? AND ?
        GROUP BY recordings.id
      SQL

      page_views = Sql.execute(sql, [site_id, from_date, to_date])

      page_views.map do |page_view|
        urls = page_view['urls'].sub('{', '').sub('}', '').split(',')
        {
          total: urls.size,
          unique: urls.tally.values.select { |x| x == 1 }.size,
          timestamp: page_view['exited_at']
        }
      end
    end
  end
end
