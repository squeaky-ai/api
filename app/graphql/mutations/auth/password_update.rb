# frozen_string_literal: true

module Mutations
  module Auth
    class PasswordUpdate < BaseMutation
      null true

      graphql_name 'AuthConfirmationsPasswordUpdate'

      argument :password, String, required: true
      argument :reset_password_token, String, required: true

      type Types::Users::User

      def resolve(password:, reset_password_token:)
        user = User.reset_password_by_token({ password:, reset_password_token: })

        unless user.errors.empty?
          Rails.logger.warn 'Update password failed for'
          raise GraphQL::ExecutionError, user.errors.full_messages.first
        end

        user
      end
    end
  end
end
