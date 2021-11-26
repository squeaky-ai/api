# frozen_string_literal: true

module Types
  module Users
    class Invitation < Types::BaseObject
      graphql_name 'UsersInvitation'

      field :email, String, null: true
      field :has_pending, Boolean, null: false
    end
  end
end
