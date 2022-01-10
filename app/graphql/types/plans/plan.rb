# frozen_string_literal: true

module Types
  module Plans
    class Plan < Types::BaseObject
      graphql_name 'Plan'

      field :max_monthly_recordings, Integer, null: false
      field :monthly_price, Integer, null: false
    end
  end
end
