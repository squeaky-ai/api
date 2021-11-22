# frozen_string_literal: true

module Types
  class SentimentType < Types::BaseObject
    description 'The sentiment object'

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
