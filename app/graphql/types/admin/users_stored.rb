# typed: false
# frozen_string_literal: true

module Types
  module Admin
    class UsersStored < Types::BaseObject
      graphql_name 'AdminUsersStored'

      field :count, Integer, null: false
      field :date, GraphQL::Types::ISO8601Date, null: false
    end
  end
end
