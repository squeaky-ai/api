# frozen_string_literal: true

module Types
  module Heatmaps
    class Item < Types::BaseUnion
      possible_types Types::Heatmaps::ClickCount,
                     Types::Heatmaps::ClickPosition,
                     Types::Heatmaps::Cursor,
                     Types::Heatmaps::Scroll

      def self.resolve_type(object, _context)
        type = object[:type] || object['type']
        case type
        when 'click_count'
          Types::Heatmaps::ClickCount
        when 'click_position'
          Types::Heatmaps::ClickPosition
        when 'cursor'
          Types::Heatmaps::Cursor
        when 'scroll'
          Types::Heatmaps::Scroll
        end
      end
    end
  end
end
