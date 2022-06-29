# frozen_string_literal: true

module Resolvers
  module Visitors
    class AverageSessionDuration < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT AVG(disconnected_at - connected_at) average_session_duration
          FROM recordings
          WHERE visitor_id = ?
        SQL

        results = Sql.execute(sql, [object.id])

        results.first['average_session_duration']
      end
    end
  end
end
