# frozen_string_literal: true

module Types
  # Average session duration by a particular visitor
  class VisitorAverageSessionDurationExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      visitor_id = object.object[:id]

      sql = <<-SQL
        SELECT AVG(disconnected_at - connected_at) average_session_duration
        FROM recordings
        WHERE visitor_id = ?
      SQL

      results = Sql.execute(sql, [visitor_id])

      results.first['average_session_duration']
    end
  end
end
