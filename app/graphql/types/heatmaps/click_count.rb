# frozen_string_literal: true

module Types
  module Heatmaps
    class ClickCount < Types::BaseObject
      graphql_name 'HeatmapsClickCount'

      field :id, ID, null: false
      field :selector, String, null: false
      field :count, Integer, null: false
    end
  end
end
