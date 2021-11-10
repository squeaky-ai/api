# frozen_string_literal: true

module Types
  # The total number of visitors
  class AnalyticsVisitorsCountExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT COUNT(DISTINCT recordings.visitor_id) total_count, COUNT(DISTINCT CASE recordings.viewed WHEN TRUE THEN NULL ELSE recordings.visitor_id END) new_count
        FROM recordings
        WHERE site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
      SQL

      results = Sql.execute(sql, [site_id, from_date, to_date])

      {
        total: results.first['total_count'],
        new: results.first['new_count']
      }
    end
  end
end
