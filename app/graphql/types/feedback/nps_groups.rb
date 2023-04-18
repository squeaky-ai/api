# typed: false
# frozen_string_literal: true

module Types
  module Feedback
    class NpsGroups < Types::BaseObject
      graphql_name 'FeedbackNpsGroups'

      field :promoters, Integer, null: false
      field :passives, Integer, null: false
      field :detractors, Integer, null: false
    end
  end
end
