# frozen_string_literal: true

module Types
  module Plans
    class Plan < Types::BaseObject
      graphql_name 'Plan'

      field :id, ID, null: false
      field :name, String, null: false
      field :max_monthly_recordings, Integer, null: true
      field :pricing, [Types::Plans::Price, { null: false }], null: true
      field :data_storage_months, Integer, null: true
      field :support, [String, { null: false }], null: true
      field :response_time_hours, Integer, null: true
      field :team_member_limit, Integer, null: true
      field :features_enabled, [String, { null: false }], null: false
    end
  end
end
