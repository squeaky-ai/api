# frozen_string_literal: true

module Resolvers
  module Heatmaps
    class Counts < Resolvers::Base
      type Types::Heatmaps::Counts, null: false

      def resolve_with_timings
        range = DateRange.new(from_date: object.from_date, to_date: object.to_date, timezone: context[:timezone])

        sql = <<-SQL
          SELECT
            COUNT(recordings.viewport_x) FILTER(WHERE recordings.viewport_x #{device_expression('Desktop')}) desktop,
            COUNT(recordings.viewport_x) FILTER(WHERE recordings.viewport_x #{device_expression('Tablet')}) tablet,
            COUNT(recordings.viewport_x) FILTER(WHERE recordings.viewport_x #{device_expression('Mobile')}) mobile
          FROM
            page_events
          LEFT JOIN
            recordings ON recordings.recording_id = page_events.recording_id
          WHERE
            site_id = :site_id AND
            like(url, :url) AND
            toDate(disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
        SQL

        variables = {
          site_id: object.site.id,
          url: Paths.replace_route_with_wildcard(object.page),
          timezone: range.timezone,
          from_date: range.from,
          to_date: range.to
        }

        Sql::ClickHouse.select_all(sql, variables).first
      end

      private

      def device_expression(device)
        ::Recording.device_expression(device)
      end
    end
  end
end
