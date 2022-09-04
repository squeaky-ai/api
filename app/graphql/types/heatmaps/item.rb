# frozen_string_literal: true

module Types
  module Heatmaps
    class Item < Types::BaseUnion
      possible_types Types::Heatmaps::Click, Types::Heatmaps::Scroll

      def self.resolve_type(object, _context)
        type = object[:type] || object['type']
        case type
        when 'click'
          Types::Heatmaps::Click
        when 'scroll'
          Types::Heatmaps::Scroll
        end
      end
    end
  end
end
