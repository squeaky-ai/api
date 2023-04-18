# frozen_string_literal: true

module Types
  module Admin
    class Users < Types::BaseObject
      graphql_name 'AdminUsers'

      field :items, [Types::Admin::User, { null: false }], null: false
      field :pagination, Types::Admin::UserPagination, null: false
    end
  end
end
