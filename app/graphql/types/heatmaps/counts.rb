# frozen_string_literal: true

module Types
  module Heatmaps
    class Counts < Types::BaseObject
      graphql_name 'HeatmapsCounts'

      field :desktop, Integer, null: false
      field :tablet, Integer, null: false
      field :mobile, Integer, null: false
    end
  end
end
