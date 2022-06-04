# frozen_string_literal: true

module Types
  module Events
    class Rule < Types::BaseObject
      graphql_name 'EventsRule'

      field :condition, Events::Condition, null: false
      field :value, String, null: false
      field :type, String, null: false
    end
  end
end
