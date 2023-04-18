# typed: false
# frozen_string_literal: true

module Types
  module Heatmaps
    class Type < Types::BaseEnum
      graphql_name 'HeatmapsType'

      value 'ClickCount', 'Show click counts'
      value 'ClickPosition', 'Show click positions'
      value 'Scroll', 'Show scrolls'
      value 'Cursor', 'Show mouse positions'
    end
  end
end
