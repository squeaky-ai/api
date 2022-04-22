# frozen_string_literal: true

module Types
  module Sites
    class Plan < Types::BaseObject
      graphql_name 'SitesPlan'

      field :tier, Integer, null: false
      field :name, String, null: false
      field :exceeded, Boolean, null: false
      field :billing_valid, Boolean, null: false
      field :recordings_limit, Integer, null: false
      field :recordings_locked_count, Integer, null: false
      field :visitors_locked_count, Integer, null: false
    end
  end
end
