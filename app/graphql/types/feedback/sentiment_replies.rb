# frozen_string_literal: true

module Types
  module Feedback
    class SentimentReplies < Types::BaseObject
      graphql_name 'FeedbackSentimentReplies'

      field :total, Integer, null: false
      field :responses, [Types::Feedback::SentimentReply, { null: true }], null: false
    end
  end
end
