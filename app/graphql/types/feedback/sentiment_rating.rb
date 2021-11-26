# frozen_string_literal: true

module Types
  module Feedback
    class SentimentRating < Types::BaseObject
      graphql_name 'FeedbackSentimentRating'

      field :score, Integer, null: false
      field :timestamp, String, null: false
    end
  end
end
