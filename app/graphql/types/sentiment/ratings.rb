# frozen_string_literal: true

module Types
  module Sentiment
    class Ratings < Types::BaseObject
      field :score, Float, null: false
      field :trend, Float, null: false
      field :responses, [SentimentRatingType, { null: true }], null: false
    end
  end
end
