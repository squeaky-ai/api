# frozen_string_literal: true

module Types
  class SentimentRatingsType < Types::BaseObject
    description 'The sentiment ratings object'

    field :score, Float, null: false
    field :trend, Float, null: false
    field :responses, [SentimentRatingType, { null: true }], null: false
  end
end
