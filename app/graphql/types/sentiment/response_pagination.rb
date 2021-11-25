# frozen_string_literal: true

module Types
  module Sentiment
    class ResponsePagination < Types::BaseObject
      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, Types::Sentiment::ResponseSort, null: false
    end
  end
end
