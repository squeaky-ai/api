# frozen_string_literal: true

module Types
  class SentimentRatingType < Types::BaseObject
    description 'The sentiment rating object'

    field :score, Integer, null: false
    field :timestamp, String, null: false
  end
end
