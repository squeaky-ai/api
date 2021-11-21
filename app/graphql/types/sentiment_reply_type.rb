# frozen_string_literal: true

module Types
  class SentimentReplyType < Types::BaseObject
    description 'The sentiment reply object'

    field :score, Integer, null: false
  end
end
