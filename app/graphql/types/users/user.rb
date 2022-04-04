# frozen_string_literal: true

module Types
  module Users
    class User < Types::BaseObject
      graphql_name 'User'

      field :id, ID, null: false
      field :first_name, String, null: true
      field :last_name, String, null: true
      field :full_name, String, null: true
      field :email, String, null: false
      field :superuser, Boolean, null: false
      field :communication, Types::Users::Communication, null: true
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
      field :last_activity_at, GraphQL::Types::ISO8601DateTime, null: true
    end
  end
end
