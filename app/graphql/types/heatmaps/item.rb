# frozen_string_literal: true

module Types
  module Heatmaps
    class Item < Types::BaseObject
      field :x, Integer, null: true
      field :y, Integer, null: true
      field :selector, String, null: true
    end
  end
end
