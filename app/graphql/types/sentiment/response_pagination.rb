# frozen_string_literal: true

module Types
  module Sentiment
    class ResponsePagination < Types::BaseObject
      graphql_name 'SentimentResponsePagination'

      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, Types::Sentiment::ResponseSort, null: false
    end
  end
end
