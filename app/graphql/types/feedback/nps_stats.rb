# typed: false
# frozen_string_literal: true

module Types
  module Feedback
    class NpsStats < Types::BaseObject
      graphql_name 'FeedbackNpsStats'

      field :displays, Integer, null: false
      field :ratings, Integer, null: false
    end
  end
end
