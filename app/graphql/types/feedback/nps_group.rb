# frozen_string_literal: true

module Types
  module Feedback
    class NpsGroup < Types::BaseEnum
      graphql_name 'FeedbackNpsGroup'

      value 'Promoter'
      value 'Passive'
      value 'Detractor'
    end
  end
end
