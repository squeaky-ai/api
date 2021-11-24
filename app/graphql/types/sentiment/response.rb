# frozen_string_literal: true

module Types
  module Sentiment
    class Response < Types::BaseObject
      field :items, [SentimentResponseItemType, { null: true }], null: false
      field :pagination, SentimentResponsePaginationType, null: false
    end
  end
end
