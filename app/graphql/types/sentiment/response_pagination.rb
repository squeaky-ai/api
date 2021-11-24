# frozen_string_literal: true

module Types
  module Sentiment
    class ResponsePagination < Types::BaseObject
      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, SentimentResponseSortType, null: false
    end
  end
end
