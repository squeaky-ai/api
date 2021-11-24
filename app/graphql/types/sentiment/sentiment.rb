# frozen_string_literal: true

module Types
  module Sentiment
    class Sentiment < Types::BaseObject
      field :responses,
            SentimentResponseType,
            null: false,
            extensions: [SentimentResponseExtension]

      field :replies,
            SentimentRepliesType,
            null: false,
            extensions: [SentimentRepliesExtension]

      field :ratings,
            SentimentRatingsType,
            null: false,
            extensions: [SentimentRatingsExtension]
    end
  end
end
