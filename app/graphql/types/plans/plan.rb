# frozen_string_literal: true

module Types
  module Plans
    class Plan < Types::BaseObject
      graphql_name 'Plan'

      field :name, String, null: false
      field :max_monthly_recordings, Integer, null: true
      field :monthly_price, Integer, null: true
    end
  end
end
