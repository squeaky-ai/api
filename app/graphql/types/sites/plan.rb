# frozen_string_literal: true

module Types
  module Sites
    class Plan < Types::BaseObject
      graphql_name 'SitesPlan'

      field :tier, Integer, null: false
      field :name, String, null: false
      field :exceeded, Boolean, null: false
      field :invalid, Boolean, null: false
      field :max_monthly_recordings, Integer, null: false
      field :data_storage_months, Integer, null: false
      field :response_time_hours, Integer, null: false
      field :support, [String, { null: false }], null: true
      field :sso_enabled, Boolean, null: false
      field :audit_trail_enabled, Boolean, null: false
      field :private_instance_enabled, Boolean, null: false
      field :notes, String, null: true
      field :team_member_limit, Integer, null: true
      field :features_enabled, [String, { null: false }], null: false
    end
  end
end
