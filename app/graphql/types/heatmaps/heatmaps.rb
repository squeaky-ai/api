# typed: false
# frozen_string_literal: true

module Types
  module Heatmaps
    class Heatmaps < Types::BaseObject
      graphql_name 'Heatmaps'

      field :counts, resolver: Resolvers::Heatmaps::Counts
      field :recording, resolver: Resolvers::Heatmaps::Recording
      field :items, resolver: Resolvers::Heatmaps::Items
    end
  end
end
