# frozen_string_literal: true

module Types
  module Teams
    class Team < Types::BaseObject
      graphql_name 'Team'

      field :id, ID, null: false
      field :status, Integer, null: false
      field :role, Integer, null: false
      field :role_name, String, null: false
      field :user, Types::Users::User, null: false
      field :linked_data_visible, Boolean, null: false
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
    end
  end
end
