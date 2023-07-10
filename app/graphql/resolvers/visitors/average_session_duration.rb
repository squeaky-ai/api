# frozen_string_literal: true

module Resolvers
  module Visitors
    class AverageSessionDuration < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            AVG(activity_duration) average_session_duration
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            visitor_id = :visitor_id
        SQL

        variables = {
          site_id: object[:site_id],
          visitor_id: object[:id]
        }

        Sql::ClickHouse.select_value(sql, variables) || 0
      end
    end
  end
end
