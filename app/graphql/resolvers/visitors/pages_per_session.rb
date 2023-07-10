# frozen_string_literal: true

module Resolvers
  module Visitors
    class PagesPerSession < Resolvers::Base
      type Float, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT AVG(count)
          FROM (
            SELECT
              recordings.uuid uuid,
              COUNT(page_events.uuid) count
            FROM
              recordings
            INNER JOIN
              page_events ON page_events.recording_id = recordings.recording_id
            WHERE
              recordings.site_id = ? AND
              recordings.visitor_id = ?
            GROUP BY
              recordings.uuid
          )
        SQL

        Sql::ClickHouse.select_value(sql, [object[:site_id], object[:id]])
      end
    end
  end
end
