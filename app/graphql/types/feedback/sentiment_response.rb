# typed: false
# frozen_string_literal: true

module Types
  module Feedback
    class SentimentResponse < Types::BaseObject
      graphql_name 'FeedbackSentimentResponse'

      field :items, [Types::Feedback::SentimentResponseItem, { null: false }], null: false
      field :pagination, Types::Feedback::SentimentResponsePagination, null: false
    end
  end
end
