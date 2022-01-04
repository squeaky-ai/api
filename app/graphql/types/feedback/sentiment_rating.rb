# frozen_string_literal: true

module Types
  module Feedback
    class SentimentRating < Types::BaseObject
      graphql_name 'FeedbackSentimentRating'

      field :score, Integer, null: false
      field :timestamp, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
