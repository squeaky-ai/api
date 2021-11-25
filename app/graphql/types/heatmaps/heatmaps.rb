# frozen_string_literal: true

module Types
  module Heatmaps
    class Heatmaps < Types::BaseObject
      field :desktop_count, Integer, null: false
      field :tablet_count, Integer, null: false
      field :mobile_count, Integer, null: false
      field :recording_id, String, null: true
      field :items, [Types::Heatmaps::Item, { null: true }], null: false
    end
  end
end
