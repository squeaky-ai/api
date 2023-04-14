# typed: false
# frozen_string_literal: true

module Types
  module Events
    class RuleInput < Types::BaseInputObject
      graphql_name 'EventsRuleInput'

      argument :matcher, Events::Match, required: true
      argument :condition, Events::Condition, required: true
      argument :value, String, required: true
      argument :field, String, required: false
    end
  end
end
