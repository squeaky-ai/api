# frozen_string_literal: true

module Types
  module Sites
    class Team < Types::BaseObject
      graphql_name 'Team'

      field :id, ID, null: false
      field :status, Integer, null: false
      field :role, Integer, null: false
      field :role_name, String, null: false
      field :user, Types::Users::User, null: false
      field :created_at, String, null: false
      field :updated_at, String, null: true
    end
  end
end
