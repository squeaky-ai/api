# frozen_string_literal: true

module Resolvers
  module Heatmaps
    class Scrolls < Resolvers::Base
      type [Types::Heatmaps::Scroll, { null: true }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            MAX((events.data->>'y')::float)
          FROM
            pages
          LEFT JOIN
            recordings ON recordings.id = pages.recording_id
          LEFT JOIN
            events ON events.recording_id = recordings.id
          WHERE
            recordings.site_id = ? AND
            recordings.status IN (?) AND
            recordings.viewport_x #{device_expression} AND
            to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
            pages.url = ? AND
            events.timestamp >= pages.entered_at AND
            events.timestamp <= pages.exited_at AND
            events.event_type = 3 AND
            (events.data->>'source')::integer = 3
          GROUP BY
            pages.id
        SQL

        variables = [
          object.site.id,
          [::Recording::ACTIVE, ::Recording::DELETED],
          object.from_date,
          object.to_date,
          object.page
        ]

        events = Sql.execute(sql, variables)
        events.map { |e| { y: e['max'] } }
      end

      private

      def device_expression
        ::Recording.device_expression(object.device)
      end
    end
  end
end
