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
      field :recordings_locked_count, Integer, null: false
      field :visitors_locked_count, Integer, null: false
      field :data_storage_months, Integer, null: false
      field :response_time_hours, Integer, null: false
      field :support, [String, { null: false }], null: true
    end
  end
end
