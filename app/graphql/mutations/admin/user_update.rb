# frozen_string_literal: true

module Mutations
  module Admin
    class UserUpdate < AdminMutation
      null false

      graphql_name 'AdminUserUpdate'

      argument :id, ID, required: true
      argument :provider_comms_email, String, required: false

      type Types::Admin::User

      def resolve(id:, **args)
        user = User.find(id)

        user.update(args)

        user
      end
    end
  end
end
