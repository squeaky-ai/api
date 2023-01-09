# frozen_string_literal: true

module Types
  module Plans
    class Price < Types::BaseObject
      graphql_name 'PlanPrice'

      field :id, String, null: false
      field :currency, Types::Common::Currency, null: false
      field :amount, Float, null: false
      field :interval, String, null: false
    end
  end
end
