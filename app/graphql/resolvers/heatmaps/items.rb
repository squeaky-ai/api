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

      def heatmaps_service
        @heatmaps_service ||= HeatmapsService.new(
          site_id: object.site.id,
          from_date: object.from_date,
          to_date: object.to_date,
          page_url: object.page,
          device: object.device
        )
      end

      def click_counts
        heatmaps_service.click_counts.map do |x|
          {
            id: Base64.encode64(x['selector']), # This is for apollo caching
            type: 'click_count',
            count: x['count'],
            selector: x['selector']
          }
        end
      end

      def click_positions
        heatmaps_service.click_positions.map do |x|
          {
            id: x['uuid'],
            type: 'click_position',
            selector: x['selector'],
            relative_to_element_x: x['relative_to_element_x'],
            relative_to_element_y: x['relative_to_element_y']
          }
        end
      end

      def cursors
        heatmaps_service.cursors.flat_map do |x|
          positions = JSON.parse(x['coordinates'])
          positions.map.with_index do |pos, index|
            {
              id: "#{x['uuid']}_#{index}",
              type: 'cursor',
              x: pos['absolute_x'] || pos['x'],
              y: pos['absolute_y'] || pos['y']
            }
          end
        end
      end

      def scrolls
        heatmaps_service.scrolls.map do |x|
          {
            id: x['recording_id'],
            type: 'scroll',
            y: x['max']
          }
        end
      end

      def device_expression
        ::Recording.device_expression(object.device)
      end
    end
  end
end
