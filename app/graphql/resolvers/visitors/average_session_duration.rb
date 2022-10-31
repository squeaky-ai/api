# frozen_string_literal: true

module Resolvers
  module Visitors
    class AverageSessionDuration < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            AVG(disconnected_at - connected_at) average_session_duration
          FROM
            recordings
          WHERE
            site_id = ? AND
            visitor_id = ?
        SQL

        Sql::ClickHouse.select_value(sql, [object.site_id, object.id])
      end
    end
  end
end
