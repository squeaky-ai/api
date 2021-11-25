# frozen_string_literal: true

module Types
  module Sentiment
    class Reply < Types::BaseObject
      graphql_name 'SentimentReply'

      field :score, Integer, null: false
    end
  end
end
