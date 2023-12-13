# frozen_string_literal: true

module Resolvers
  module Heatmaps
    class Items < Resolvers::Base
      type String, null: false # The whole thing is stringified because it creates too many objects

      def resolve
        case object.type
        when 'ClickCount'
          heatmaps_instance.click_counts.to_json
        when 'ClickPosition'
          heatmaps_instance.click_positions.to_json
        when 'Cursor'
          heatmaps_instance.cursors.to_json
        when 'Scroll'
          heatmaps_instance.scrolls.to_json
        end
      end

      private

      def heatmaps_instance
        range = DateRange.new(from_date: object.from_date, to_date: object.to_date, timezone: context[:timezone])

        @heatmaps_instance ||= HeatmapsService.new(
          site_id: object.site.id,
          range:,
          page_url: object.page,
          device: object.device
        )
      end
    end
  end
end
