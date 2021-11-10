# frozen_string_literal: true

module Types
  # The dimensions
  class AnalyticsDimensionsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT device_x
        FROM recordings
        WHERE device_x > 0 AND site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?
      SQL

      results = Sql.execute(sql, [site_id, from_date, to_date])

      results.map { |r| r['device_x'] }
    end
  end
end
