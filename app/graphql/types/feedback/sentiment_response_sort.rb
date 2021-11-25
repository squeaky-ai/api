# frozen_string_literal: true

module Types
  module Feedback
    class SentimentResponseSort < Types::BaseEnum
      graphql_name 'FeedbackSentimentResponseSort'

      value 'timestamp__desc', 'Most recent response first'
      value 'timestamp__asc', 'Oldest response first'
    end
  end
end
