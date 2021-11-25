# frozen_string_literal: true

module Types
  module Sentiment
    class Replies < Types::BaseObject
      graphql_name 'SentimentReplies'

      field :total, Integer, null: false
      field :responses, [Types::Sentiment::Reply, { null: true }], null: false
    end
  end
end
