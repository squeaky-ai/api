# frozen_string_literal: true

module Types
  module Heatmaps
    class Heatmaps < Types::BaseObject
      graphql_name 'Heatmaps'

      field :counts, resolver: Resolvers::Heatmaps::Counts
      field :recording, resolver: Resolvers::Heatmaps::Recording
      field :clicks, resolver: Resolvers::Heatmaps::Clicks
      field :scrolls, resolver: Resolvers::Heatmaps::Scrolls
      field :cursors, resolver: Resolvers::Heatmaps::Cursors
    end
  end
end
