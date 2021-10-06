# frozen_string_literal: true

module Types
  class HeatmapsItemType < Types::BaseObject
    description 'The heatmaps item'

    field :x, Integer, null: false
    field :y, Integer, null: false
    field :id, Integer, null: false
  end
end
