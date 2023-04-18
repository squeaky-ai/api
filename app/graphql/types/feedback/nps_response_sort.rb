# frozen_string_literal: true

module Types
  module Feedback
    class NpsResponseSort < Types::BaseEnum
      graphql_name 'FeedbackNpsResponseSort'

      value 'timestamp__desc', 'Most recent response first'
      value 'timestamp__asc', 'Oldest response first'
    end
  end
end
