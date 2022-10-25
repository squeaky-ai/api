# frozen_string_literal: true

module Types
  module Feedback
    class SentimentRatings < Types::BaseObject
      graphql_name 'FeedbackSentimentRatings'

      field :score, Float, null: false
      field :trend, Float, null: false
      field :responses, [Types::Feedback::SentimentRating, { null: false }], null: false
    end
  end
end
