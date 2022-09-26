# frozen_string_literal: true

module Types
  module Heatmaps
    class Type < Types::BaseEnum
      graphql_name 'HeatmapsType'

      value 'Click', 'Show clicks'
      value 'Scroll', 'Show scrolls'
      value 'Cursor', 'Show mouse positions'
    end
  end
end
