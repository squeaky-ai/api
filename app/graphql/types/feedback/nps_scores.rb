# typed: false
# frozen_string_literal: true

module Types
  module Feedback
    class NpsScores < Types::BaseObject
      graphql_name 'FeedbackNpsScores'

      field :trend, Integer, null: false
      field :score, Integer, null: false
      field :responses, [Types::Feedback::NpsScore, { null: false }], null: false
    end
  end
end
