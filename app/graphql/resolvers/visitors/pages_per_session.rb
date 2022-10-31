# frozen_string_literal: true

module Resolvers
  module Visitors
    class PagesPerSession < Resolvers::Base
      type Float, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            recordings.uuid uuid,
            count(page_events.uuid) count
          FROM
            recordings
          INNER JOIN
            page_events ON page_events.recording_id = recordings.recording_id
          WHERE
            recordings.site_id = ? AND
            recordings.visitor_id = ?
          GROUP BY
            recordings.uuid
        SQL

        results = Sql::ClickHouse.select_all(sql, [object.site_id, object.id])

        Maths.average(results.map { |r| r['count'] })
      end
    end
  end
end
