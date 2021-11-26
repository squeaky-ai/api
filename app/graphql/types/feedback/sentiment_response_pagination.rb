# frozen_string_literal: true

module Types
  module Feedback
    class SentimentResponsePagination < Types::BaseObject
      graphql_name 'FeedbackSentimentResponsePagination'

      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, Types::Feedback::SentimentResponseSort, null: false
    end
  end
end
