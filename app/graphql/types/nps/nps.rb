# frozen_string_literal: true

module Types
  module Nps
    class Nps < Types::BaseObject
      graphql_name 'Nps'

      field :responses, resolver: Resolvers::Nps::Response
      field :groups, resolver: Resolvers::Nps::Groups
      field :stats, resolver: Resolvers::Nps::Stats
      field :ratings, resolver: Resolvers::Nps::Ratings
      field :replies, resolver: Resolvers::Nps::Replies
      field :scores, resolver: Resolvers::Nps::Scores
    end
  end
end
