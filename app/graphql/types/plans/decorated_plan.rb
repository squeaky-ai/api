# frozen_string_literal: true

module Types
  module Plans
    class DecoratedPlan < Types::BaseObject
      graphql_name 'DecoratedPlan'

      field :name, String, null: false
      field :plan, Types::Plans::Plan, null: true
      field :description, String, null: true
      field :show, Boolean, null: false
      field :current, Boolean, null: false
      field :usage, [String, { null: false }], null: false
      field :includes_capabilities_from, String, null: true
      field :capabilities, [String, { null: false }], null: false
      field :options, [String, { null: false }], null: false
    end
  end
end
