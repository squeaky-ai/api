# frozen_string_literal: true

module Types
  class HeatmapsType < Types::BaseObject
    description 'The heatmaps object'

    field :desktop_count, Integer, null: false
    field :mobile_count, Integer, null: false
    field :screenshot_url, String, null: true
    field :items, [HeatmapsItemType, { null: true }], null: false
  end
end
