# frozen_string_literal: true

module Types
  # The total number of recordings
  class AnalyticsRecordingsCountExtension < AnalyticsQuery
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT COUNT(recordings),
               COUNT(CASE recordings.viewed WHEN TRUE THEN NULL ELSE 1 END)
        FROM recordings
        WHERE site_id = ? AND created_at::date BETWEEN ? AND ?;
      SQL

      result = execute_sql(sql, [site_id, from_date, to_date])[0]

      {
        total: result[0].to_i,
        new: result[1].to_i
      }
    end
  end
end