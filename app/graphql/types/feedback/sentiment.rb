# frozen_string_literal: true

module Types
  module Feedback
    class Sentiment < Types::BaseObject
      graphql_name 'Sentiment'

      field :responses, resolver: Resolvers::Feedback::SentimentResponse
      field :replies, resolver: Resolvers::Feedback::SentimentReplies
      field :ratings, resolver: Resolvers::Feedback::SentimentRatings
    end
  end
end
