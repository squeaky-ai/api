# frozen_string_literal: true

module Types
  module Feedback
    class NpsResponseFilters < BaseInputObject
      graphql_name 'FeedbackNpsResponseFilters'

      argument :follow_up_comment, Boolean, required: false
      argument :outcome_type, Types::Feedback::NpsGroup, required: false
    end
  end
end
