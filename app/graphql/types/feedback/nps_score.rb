# frozen_string_literal: true

module Types
  module Feedback
    class NpsScore < Types::BaseObject
      graphql_name 'FeedbackNpsScore'

      field :score, Integer, null: false
      field :timestamp, String, null: false
    end
  end
end
