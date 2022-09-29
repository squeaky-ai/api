# frozen_string_literal: true

module Types
  module Heatmaps
    class ClickPosition < Types::BaseObject
      graphql_name 'HeatmapsClickPosition'

      field :id, ID, null: false
      field :selector, String, null: false
      field :relative_to_element_x, Integer, null: false
      field :relative_to_element_y, Integer, null: false
    end
  end
end
