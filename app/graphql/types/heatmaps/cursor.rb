# frozen_string_literal: true

module Types
  module Heatmaps
    class Cursor < Types::BaseObject
      graphql_name 'HeatmapsCursor'

      field :x, Integer, null: false
      field :y, Integer, null: false
    end
  end
end
