# typed: false
# frozen_string_literal: true

module Types
  module Feedback
    class Nps < Types::BaseObject
      graphql_name 'Nps'

      field :responses, resolver: Resolvers::Feedback::NpsResponse
      field :groups, resolver: Resolvers::Feedback::NpsGroups
      field :stats, resolver: Resolvers::Feedback::NpsStats
      field :ratings, resolver: Resolvers::Feedback::NpsRatings
      field :replies, resolver: Resolvers::Feedback::NpsReplies
      field :scores, resolver: Resolvers::Feedback::NpsScores
    end
  end
end
