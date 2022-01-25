# frozen_string_literal: true

module Types
  module Heatmaps
    class Item < Types::BaseObject
      graphql_name 'HeatmapsItem'

      # TODO: Make this a union

      field :x, Integer, null: true
      field :y, Integer, null: true
      field :selector, String, null: true
      field :count, Integer, null: true
    end
  end
end
