# frozen_string_literal: true

module Types
  module Events
    class Condition < Types::BaseEnum
      graphql_name 'EventsCondition'

      value 'and', ''
      value 'or', ''
    end
  end
end
