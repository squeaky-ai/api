# frozen_string_literal: true

module Types
  # The total number of page views
  class AnalyticsPageViewCountExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT COUNT(pages.id) pages_count
        FROM pages
        LEFT JOIN recordings ON recordings.id = pages.recording_id
        WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
      SQL

      results = Sql.execute(sql, [site_id, from_date, to_date])

      results.first['pages_count']
    end
  end
end
