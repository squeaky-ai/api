# frozen_string_literal: true

module Types
  class SentimentRepliesType < Types::BaseObject
    description 'The sentiment replies object'

    field :total, Integer, null: false
    field :responses, [SentimentReplyType, { null: true }], null: false
  end
end
