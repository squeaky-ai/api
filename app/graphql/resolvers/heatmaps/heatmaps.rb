# frozen_string_literal: true

module Resolvers
  module Heatmaps
    class Heatmaps < Resolvers::Base
      type Types::Heatmaps::Heatmaps, null: false

      MOBILE_BREAKPOINT = 320
      TABLET_BREAKPOINT = 800
      DESKTOP_BREAKPOINT = 1280

      argument :device, Types::Heatmaps::Device, required: true, default_value: 'Desktop'
      argument :type, Types::Heatmaps::Type, required: true, default_value: 'Click'
      argument :page, String, required: true
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true
      argument :exclude_recording_ids, [ID], required: false, default_value: []

      def resolve(device:, type:, page:, from_date:, to_date:, exclude_recording_ids:)
        device_counts = devices(page, from_date, to_date)
        items = type == 'Click' ? click_events(from_date, to_date, page, device) : scroll_events(from_date, to_date, page, device)

        {
          **device_counts,
          items: items.compact,
          recording_id: suitable_recording(page, device, from_date, to_date, exclude_recording_ids)
        }
      end

      private

      def devices(page, from_date, to_date)
        sql = <<-SQL
          SELECT
            COUNT(recordings.viewport_x) FILTER(WHERE recordings.viewport_x #{device_expression('Desktop')}) desktop_count,
            COUNT(recordings.viewport_x) FILTER(WHERE recordings.viewport_x #{device_expression('Tablet')}) tablet_count,
            COUNT(recordings.viewport_x) FILTER(WHERE recordings.viewport_x #{device_expression('Mobile')}) mobile_count
          FROM
            pages
          LEFT JOIN
            recordings ON recordings.id = pages.recording_id
          WHERE
            recordings.site_id = ? AND
            recordings.status IN (?) AND
            pages.url = ? AND
            to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
        SQL

        variables = [
          object.id,
          [Recording::ACTIVE, Recording::DELETED],
          page,
          from_date,
          to_date
        ]

        Sql.execute(sql, variables).first
      end

      def suitable_recording(page, device, from_date, to_date, exclude_recording_ids)
        sql = <<-SQL
          SELECT
            recording_id
          FROM
            pages
          LEFT JOIN
            recordings ON recordings.id = pages.recording_id
          WHERE
            recordings.id NOT IN (?) AND
            recordings.site_id = ? AND
            recordings.status IN (?) AND
            pages.url = ? AND
            recordings.viewport_x #{device_expression(device)} AND
            to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
          ORDER BY
            (recordings.disconnected_at - recordings.connected_at) ASC
          LIMIT
            1;
        SQL

        variables = [
          exclude_recording_ids.empty? ? [0] : exclude_recording_ids,
          object.id,
          [Recording::ACTIVE, Recording::DELETED],
          page,
          from_date,
          to_date
        ]

        pages = Sql.execute(sql, variables)
        pages.first&.[]('recording_id')
      end

      def click_events(from_date, to_date, page, device)
        if ClickHouseMigration.read?(object.id)
          click_events_from_clickhouse(from_date, to_date, page, device)
        else
          click_events_from_postgres(from_date, to_date, page, device)
        end
      end

      def click_events_from_clickhouse(from_date, to_date, page, device)
        sql = <<-SQL
          SELECT
            DISTINCT(clicks.selector) selector,
            COUNT(*) count
          FROM (
            SELECT JSONExtractString(data, 'selector') selector, JSONExtractString(data, 'href') href, toDateTime(timestamp / 1000) clicked_at, site_id
            FROM events
            WHERE type = 3 AND source = 2 AND site_id = ? AND clicked_at BETWEEN ? AND ? AND href = ? AND recording_id IN ?
          ) clicks
          GROUP BY selector
          ORDER BY count DESC;
        SQL

        variables = [
          object.id,
          from_date,
          to_date,
          page,
          recordings_ids_for_device(from_date, to_date, device)
        ]

        query = ActiveRecord::Base.sanitize_sql_array([sql, *variables])

        ClickHouse.connection.select_all(query)
      end

      def recordings_ids_for_device(from_date, to_date, device)
        sql = <<-SQL
          SELECT
            id
          FROM
            recordings
          WHERE
            site_id = ? AND
            viewport_x #{device_expression(device)} AND
            to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?
        SQL

        variables = [
          object.id,
          from_date,
          to_date
        ]

        Sql.execute(sql, variables).map { |x| x['id'] }
      end

      def click_events_from_postgres(from_date, to_date, page, device)
        sql = <<-SQL
          SELECT
            DISTINCT(selector) AS selector,
            COUNT(*) count
          FROM
            clicks
          WHERE
            site_id = ? AND
            viewport_x #{device_expression(device)} AND
            to_timestamp(clicked_at / 1000)::date BETWEEN ? AND ? AND
            page_url = ?
          GROUP BY selector
          ORDER BY count DESC
        SQL

        variables = [
          object.id,
          from_date,
          to_date,
          page
        ]

        Sql.execute(sql, variables)
      end

      def scroll_events(from_date, to_date, page, device)
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
            recordings.viewport_x #{device_expression(device)} AND
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
          object.id,
          [Recording::ACTIVE, Recording::DELETED],
          from_date,
          to_date,
          page
        ]

        events = Sql.execute(sql, variables)
        events.map { |e| { y: e['max'] } }
      end

      def device_expression(device)
        case device
        when 'Mobile'
          "BETWEEN #{MOBILE_BREAKPOINT} AND #{TABLET_BREAKPOINT}"
        when 'Tablet'
          "BETWEEN #{TABLET_BREAKPOINT} AND #{DESKTOP_BREAKPOINT}"
        when 'Desktop'
          ">= #{DESKTOP_BREAKPOINT}"
        end
      end
    end
  end
end
