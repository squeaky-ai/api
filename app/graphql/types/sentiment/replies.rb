# frozen_string_literal: true

module Types
  module Sentiment
    class Replies < Types::BaseObject
      field :total, Integer, null: false
      field :responses, [SentimentReplyType, { null: true }], null: false
    end
  end
end
