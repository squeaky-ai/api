# frozen_string_literal: true

module Resolvers
  module Heatmaps
    class Heatmaps < Resolvers::Base
      type Types::Heatmaps::Heatmaps, null: false

      MOBILE_BREAKPOINT = 380
      TABLET_BREAKPOINT = 800

      argument :device, Types::Heatmaps::Device, required: true, default_value: 'Desktop'
      argument :type, Types::Heatmaps::Type, required: true, default_value: 'Click'
      argument :page, String, required: true
      argument :from_date, String, required: true
      argument :to_date, String, required: true

      def resolve(device:, type:, page:, from_date:, to_date:)
        device_counts = devices(object[:site_id], page, from_date, to_date)
        items = type == 'Click' ? click_events(site_id, from_date, to_date, page, device) : scroll_events(site_id, from_date, to_date, page, device)

        {
          **device_counts,
          items: items.compact,
          recording_id: suitable_recording(site_id, page, from_date, to_date)
        }
      end

      private

      def devices(site_id, page, from_date, to_date)
        sql = <<-SQL
          SELECT
            recordings.viewport_x
          FROM
            pages
          LEFT JOIN
            recordings ON recordings.id = pages.recording_id
          WHERE
            recordings.site_id = ? AND
            pages.url = ?
            AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
        SQL

        viewports = Sql.execute(sql, [site_id, page, from_date, to_date])

        group_viewports(viewports.map { |v| v['viewport_x'] })
      end

      def suitable_recording(site_id, page, from_date, to_date)
        # TODO: I think this query should try and pull back the smallest
        # recording possible by joining the events and checking the count
        sql = <<-SQL
          SELECT
            recording_id
          FROM
            pages
          LEFT JOIN
            recordings ON recordings.id = pages.recording_id
          WHERE
            deleted = false AND
            recordings.site_id = ? AND
            pages.url = ? AND
            to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
          LIMIT
            1;
        SQL

        pages = Sql.execute(sql, [site_id, page, from_date, to_date])
        pages.first&.[]('recording_id')
      end

      def click_events(site_id, from_date, to_date, page, device)
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
            recordings.viewport_x #{device_expression(device)} AND
            to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
            pages.url = ? AND
            events.timestamp >= pages.entered_at AND
            events.timestamp <= pages.exited_at AND
            events.event_type = 3 AND
            (events.data->>'source')::integer = 2 AND
            (events.data->>'type')::integer = 2
        SQL

        events = Sql.execute(sql, [site_id, from_date, to_date, page])
        events.map { |e| JSON.parse(e['data']) }
      end

      def scroll_events(site_id, from_date, to_date, page, device)
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
            recordings.viewport_x #{device_expression(device)} AND
            to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
            pages.url = ? AND
            events.timestamp >= pages.entered_at AND
            events.timestamp <= pages.exited_at AND
            events.event_type = 3 AND
            (events.data->>'source')::integer = 3
          GROUP BY
            pages.id;
        SQL

        events = Sql.execute(sql, [site_id, from_date, to_date, page])
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

      def group_viewports(viewports)
        out = { mobile_count: 0, tablet_count: 0, desktop_count: 0 }

        viewports.each do |v|
          if v <= MOBILE_BREAKPOINT
            out[:mobile_count] += 1
          elsif v > MOBILE_BREAKPOINT && v <= TABLET_BREAKPOINT
            out[:tablet_count] += 1
          else
            out[:desktop_count] += 1
          end
        end

        out
      end
    end
  end
end
