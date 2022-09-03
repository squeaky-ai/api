# frozen_string_literal: true

module Types
  module Heatmaps
    class Scroll < Types::BaseObject
      graphql_name 'HeatmapsScroll'

      field :x, Integer, null: true
      field :y, Integer, null: false
    end
  end
end
