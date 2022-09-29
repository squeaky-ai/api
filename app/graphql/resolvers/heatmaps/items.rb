# frozen_string_literal: true

module Resolvers
  module Heatmaps
    class Items < Resolvers::Base
      type [Types::Heatmaps::Item, { null: true }], null: false

      def resolve_with_timings
        case object.type
        when 'ClickCount'
          click_counts
        when 'ClickPosition'
          click_positions
        when 'Cursor'
          cursors
        when 'Scroll'
          scrolls
        end
      end

      private

      def click_counts
        # TODO: Replace with ClickHouse
        sql = <<-SQL
          SELECT
            DISTINCT(selector) AS selector,
            COUNT(*) count
          FROM
            clicks
          WHERE
            site_id = ? AND
            viewport_x #{device_expression} AND
            to_timestamp(clicked_at / 1000)::date BETWEEN ? AND ? AND
            page_url = ?
          GROUP BY selector
          ORDER BY count DESC
        SQL

        variables = [
          object.site.id,
          object.from_date,
          object.to_date,
          object.page
        ]

        events = Sql.execute(sql, variables)

        events.map do |x|
          {
            id: Base64.encode64(x['selector']), # This is for apollo caching
            type: 'click_count',
            count: x['count'],
            selector: x['selector']
          }
        end
      end

      def click_positions # rubocop:disable Metrics/AbcSize
        sql = <<-SQL
          SELECT
            selector,
            relative_to_element_x,
            relative_to_element_y
          FROM
            clicks
          WHERE
            site_id = ? AND
            viewport_x #{device_expression} AND
            to_timestamp(clicked_at / 1000)::date BETWEEN ? AND ? AND
            page_url = ? AND
            relative_to_element_x IS NOT NULL AND
            relative_to_element_y IS NOT NULL
        SQL

        variables = [
          object.site.id,
          object.from_date,
          object.to_date,
          object.page
        ]

        events = Sql.execute(sql, variables)

        events.map do |x|
          {
            id: Base64.encode64(x['selector']), # This is for apollo caching
            type: 'click_position',
            selector: x['selector'],
            relative_to_element_x: x['relative_to_element_x'],
            relative_to_element_y: x['relative_to_element_y']
          }
        end
      end

      def cursors # rubocop:disable Metrics/AbcSize
        sql = <<-SQL
          SELECT
            events.id,
            events.data->>'positions' as positions
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
            (events.data->>'source')::integer = 1
        SQL

        variables = [
          object.site.id,
          [::Recording::ACTIVE, ::Recording::DELETED],
          object.from_date,
          object.to_date,
          object.page
        ]

        events = Sql.execute(sql, variables)

        events.flat_map do |e|
          positions = JSON.parse(e['positions'])
          positions.map.with_index do |pos, index|
            {
              x: pos['absoluteX'] || pos['x'],
              y: pos['absoluteY'] || pos['y'],
              id: "#{e['id']}_#{index}", # This is for apollo cache
              type: 'cursor' # This is to resolve the union
            }
          end
        end
      end

      def scrolls
        sql = <<-SQL
          SELECT
            pages.id,
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
        events.map do |e|
          { y: e['max'], id: e['id'], type: 'scroll' }
        end
      end

      def device_expression
        ::Recording.device_expression(object.device)
      end
    end
  end
end
