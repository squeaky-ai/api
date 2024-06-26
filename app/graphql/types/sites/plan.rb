# frozen_string_literal: true

module Types
  module Sites
    class Plan < Types::BaseObject
      graphql_name 'SitesPlan'

      field :id, ID, null: false
      field :plan_id, String, null: false
      field :name, String, null: false
      field :exceeded, Boolean, null: false, method: :exceeded?
      field :invalid, Boolean, null: false, method: :invalid?
      field :max_monthly_recordings, Integer, null: false
      field :fractional_usage, Integer, null: false
      field :current_month_recordings_count, Integer, null: false
      field :data_storage_months, Integer, null: false
      field :response_time_hours, Integer, null: false
      field :support, [String, { null: false }], null: true
      field :sso_enabled, Boolean, null: false
      field :audit_trail_enabled, Boolean, null: false
      field :private_instance_enabled, Boolean, null: false
      field :notes, String, null: true
      field :team_member_limit, Integer, null: true
      field :features_enabled, [Types::Plans::Feature, { null: false }], null: false
      field :deprecated, Boolean, null: false, method: :deprecated?
      field :free, Boolean, null: false, method: :free?
      field :enterprise, Boolean, null: false, method: :enterprise?
      field :site_limit, Integer, null: true
      field :pricing, [Types::Plans::Price, { null: false }], null: true
    end
  end
end
