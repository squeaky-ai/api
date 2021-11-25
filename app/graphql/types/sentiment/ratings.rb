# frozen_string_literal: true

module Types
  module Sentiment
    class Ratings < Types::BaseObject
      graphql_name 'SentimentRatings'

      field :score, Float, null: false
      field :trend, Float, null: false
      field :responses, [Types::Sentiment::Rating, { null: true }], null: false
    end
  end
end
