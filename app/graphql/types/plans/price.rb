# frozen_string_literal: true

module Types
  module Plans
    class Price < Types::BaseObject
      graphql_name 'PlanPrice'

      field :id, String, null: false
      field :currency, Types::Plans::Currency, null: false
      field :amount, Integer, null: false
    end
  end
end
