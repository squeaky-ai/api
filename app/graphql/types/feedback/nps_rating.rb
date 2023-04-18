# typed: false
# frozen_string_literal: true

module Types
  module Feedback
    class NpsRating < Types::BaseObject
      graphql_name 'FeedbackNpsRatings'

      field :score, Integer, null: false
    end
  end
end
