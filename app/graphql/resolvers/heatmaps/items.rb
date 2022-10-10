# frozen_string_literal: true

module Resolvers
  module Heatmaps
    class Items < Resolvers::Base
      type [Types::Heatmaps::Item, { null: true }], null: false

      argument :cluster, Integer, required: false, default_value: 8

      def resolve_with_timings(cluster:)
        case object.type
        when 'ClickCount'
          click_counts
        when 'ClickPosition'
          click_positions
        when 'Cursor'
          cursors(cluster)
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

      def cursors(cluster)
        uuid = SecureRandom.uuid
        heatmaps_service.cursors(cluster).map.with_index do |x, index|
          {
            id: "#{uuid}_#{index}", # Not interested in caching this anyway
            type: 'cursor',
            x: x['x'],
            y: x['y'],
            count: x['count']
          }
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
