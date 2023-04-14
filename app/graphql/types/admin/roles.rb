# typed: false
# frozen_string_literal: true

module Types
  module Admin
    class Roles < Types::BaseObject
      graphql_name 'AdminRoles'

      field :owners, Integer, null: false
      field :admins, Integer, null: false
      field :members, Integer, null: false
      field :readonly, Integer, null: false
    end
  end
end
