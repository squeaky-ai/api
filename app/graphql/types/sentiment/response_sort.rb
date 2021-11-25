# frozen_string_literal: true

module Types
  module Sentiment
    class ResponseSort < Types::BaseEnum
      graphql_name 'SentimentResponseSort'

      value 'timestamp__desc', 'Most recent response first'
      value 'timestamp__asc', 'Oldest response first'
    end
  end
end
