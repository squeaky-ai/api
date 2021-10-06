# frozen_string_literal: true

module Types
  class HeatmapsType < Types::BaseObject
    description 'The heatmaps object'

    field :desktop_count, Integer, null: false
    field :mobile_count, Integer, null: false
    field :items, [HeatmapsItemType, { null: true }], null: false
  end
end
