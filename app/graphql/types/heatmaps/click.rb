# frozen_string_literal: true

module Types
  module Heatmaps
    class Click < Types::BaseObject
      graphql_name 'HeatmapsClick'

      field :id, ID, null: false
      field :selector, String, null: false
      field :count, Integer, null: false
    end
  end
end