# frozen_string_literal: true

module Resolvers
  module Heatmaps
    class Recording < Resolvers::Base
      type 'Types::Recordings::Recording', null: true

      MIN_PAGE_DURATION = 3000

      def resolve_with_timings
        ::Recording
          .joins(:pages, :visitor)
          .preload(:pages, :visitor)
          .find_by(site_id: object.site.id, id: suitable_recording_id)
      end

      private

      def suitable_recording_id # rubocop:disable Metrics/AbcSize
        sql = <<-SQL
          SELECT
            recording_id
          FROM
            page_events
          LEFT JOIN
            recordings ON recordings.recording_id = page_events.recording_id
          WHERE
            recordings.recording_id NOT IN (?) AND
            recordings.site_id = ? AND
            page_events.url = ? AND
            page_events.exited_at - page_events.entered_at >= #{MIN_PAGE_DURATION} AND
            recordings.viewport_x #{device_expression} AND
            toDate(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
          ORDER BY
            (recordings.disconnected_at - recordings.connected_at) ASC
          LIMIT
            1;
        SQL

        variables = [
          object.exclude_recording_ids.empty? ? [0] : object.exclude_recording_ids,
          object.site.id,
          object.page,
          object.from_date,
          object.to_date
        ]

        Sql::ClickHouse.select_all(sql, variables).first&.[]('recording_id')
      end

      def device_expression
        ::Recording.device_expression(object.device)
      end
    end
  end
end
