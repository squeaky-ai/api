# frozen_string_literal: true

module Types
  module Heatmaps
    class Cursor < Types::BaseObject
      graphql_name 'HeatmapsCursor'

      field :id, ID, null: false
      field :x, Integer, null: false
      field :y, Integer, null: false
      field :count, Integer, null: false
    end
  end
end
