# typed: false
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
        range = DateRange.new(from_date: object.from_date, to_date: object.to_date, timezone: context[:timezone])

        sql = <<-SQL
          SELECT
            recording_id
          FROM
            page_events
          LEFT JOIN
            recordings ON recordings.recording_id = page_events.recording_id
          WHERE
            recordings.recording_id NOT IN (:recording_ids) AND
            recordings.site_id = :site_id AND
            like(page_events.url, :url) AND
            page_events.exited_at - page_events.entered_at >= #{MIN_PAGE_DURATION} AND
            recordings.viewport_x #{device_expression} AND
            toDate(recordings.disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
          ORDER BY
            (recordings.disconnected_at - recordings.connected_at) ASC
          LIMIT
            1;
        SQL

        variables = {
          recording_ids: object.exclude_recording_ids.empty? ? [0] : object.exclude_recording_ids,
          site_id: object.site.id,
          url: Paths.replace_route_with_wildcard(object.page),
          timezone: range.timezone,
          from_date: range.from,
          to_date: range.to
        }

        Sql::ClickHouse.select_all(sql, variables).first&.[]('recording_id')
      end

      def device_expression
        ::Recording.device_expression(object.device)
      end
    end
  end
end
