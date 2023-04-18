# typed: false
# frozen_string_literal: true

module Types
  module Feedback
    class SentimentReply < Types::BaseObject
      graphql_name 'FeedbackSentimentReply'

      field :score, Integer, null: false
    end
  end
end
