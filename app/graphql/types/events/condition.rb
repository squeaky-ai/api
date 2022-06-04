# frozen_string_literal: true

module Types
  module Events
    class Condition < Types::BaseEnum
      graphql_name 'EventsCondition'

      value 'equals', 'Exactly equals'
      value 'not_equals', 'Does not exactly equal'
      value 'contains', 'Contains'
      value 'not_contains', 'Does not contain'
      value 'starts_with', 'Starts with'
    end
  end
end
