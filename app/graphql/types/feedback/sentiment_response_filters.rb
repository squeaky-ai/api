# typed: false
# frozen_string_literal: true

module Types
  module Feedback
    class SentimentResponseFilters < BaseInputObject
      graphql_name 'FeedbackSentimentResponseFilters'

      argument :follow_up_comment, Boolean, required: false
      argument :rating, Integer, required: false
    end
  end
end
