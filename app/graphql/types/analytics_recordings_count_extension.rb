# frozen_string_literal: true

module Types
  # The total number of recordings
  class AnalyticsRecordingsCountExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT COUNT(recordings) total_count, COUNT(CASE recordings.viewed WHEN TRUE THEN NULL ELSE 1 END) new_count
        FROM recordings
        WHERE site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?
      SQL

      results = Sql.execute(sql, [site_id, from_date, to_date])

      {
        total: results.first['total_count'],
        new: results.first['new_count']
      }
    end
  end
end
