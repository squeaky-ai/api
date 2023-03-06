# frozen_string_literal: true

module Types
  module Events
    class Rule < Types::BaseObject
      graphql_name 'EventsRule'

      field :matcher, Events::Match, null: false
      field :condition, Events::Condition, null: false
      field :value, String, null: false
      field :field, String, null: true
    end
  end
end
