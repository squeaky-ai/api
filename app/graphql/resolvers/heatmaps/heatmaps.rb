# frozen_string_literal: true

module Resolvers
  module Heatmaps
    class Heatmaps < Resolvers::Base
      type Types::Heatmaps::Heatmaps, null: false

      MOBILE_BREAKPOINT = 380
      TABLET_BREAKPOINT = 800
      LIMIT_SO_IT_LOADS_ON_BIG_SITES = 1000 # TODO: Performance is terrible

      argument :device, Types::Heatmaps::Device, required: true, default_value: 'Desktop'
      argument :type, Types::Heatmaps::Type, required: true, default_value: 'Click'
      argument :page, String, required: true
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve(device:, type:, page:, from_date:, to_date:)
        device_counts = devices(page, from_date, to_date)
        items = type == 'Click' ? click_events(from_date, to_date, page, device) : scroll_events(from_date, to_date, page, device)

        {
          **device_counts,
          items: items.compact,
          recording_id: suitable_recording(page, device, from_date, to_date)
        }
      end

      private

      def devices(page, from_date, to_date)
        sql = <<-SQL
          SELECT
            COUNT(recordings.viewport_x) FILTER(WHERE recordings.viewport_x > #{TABLET_BREAKPOINT}) desktop_count,
            COUNT(recordings.viewport_x) FILTER(WHERE recordings.viewport_x > #{MOBILE_BREAKPOINT} AND recordings.viewport_x <= #{TABLET_BREAKPOINT}) tablet_count,
            COUNT(recordings.viewport_x) FILTER(WHERE recordings.viewport_x <= #{TABLET_BREAKPOINT}) mobile_count
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

      def suitable_recording(page, device, from_date, to_date)
        sql = <<-SQL
          SELECT
            recording_id
          FROM
            pages
          LEFT JOIN
            recordings ON recordings.id = pages.recording_id
          WHERE
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
        sql = <<-SQL
          SELECT
            events.data
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
            (events.data->>'source')::integer = 2 AND
            (events.data->>'type')::integer = 2
          LIMIT #{LIMIT_SO_IT_LOADS_ON_BIG_SITES}
        SQL

        variables = [
          object.id,
          [Recording::ACTIVE, Recording::DELETED],
          from_date,
          to_date,
          page
        ]

        events = Sql.execute(sql, variables)
        events.map { |e| JSON.parse(e['data']) }
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
            pages.id;
          LIMIT #{LIMIT_SO_IT_LOADS_ON_BIG_SITES}
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
          "<= #{MOBILE_BREAKPOINT}"
        when 'Tablet'
          "BETWEEN #{MOBILE_BREAKPOINT} AND #{TABLET_BREAKPOINT}"
        when 'Desktop'
          "> #{TABLET_BREAKPOINT}"
        end
      end
    end
  end
end
