# frozen_string_literal: true

module Types
  module Plans
    class MonthlyPrice < Types::BaseObject
      graphql_name 'PlanMonthlyPrice'

      field :GBP, Integer, null: false
      field :EUR, Integer, null: false
      field :USD, Integer, null: false
    end
  end
end
