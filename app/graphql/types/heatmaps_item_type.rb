# frozen_string_literal: true

module Types
  class HeatmapsItemType < Types::BaseObject
    description 'The heatmaps item'

    field :x, Integer, null: true
    field :y, Integer, null: true
    field :selector, String, null: true
  end
end
