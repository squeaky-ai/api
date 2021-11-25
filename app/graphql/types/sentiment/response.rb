# frozen_string_literal: true

module Types
  module Sentiment
    class Response < Types::BaseObject
      field :items, [Types::Sentiment::ResponseItem, { null: true }], null: false
      field :pagination, Types::Sentiment::ResponsePagination, null: false
    end
  end
end
