# frozen_string_literal: true

module Mutations
  module Auth
    class Confirm < BaseMutation
      null true

      graphql_name 'AuthConfirm'

      argument :token, String, required: true

      type Types::Users::User

      def resolve(token:)
        user = User.confirm_by_token(token)

        unless user.errors.empty?
          Rails.logger.warn "Sign up token was incorrect #{token}"
          raise GraphQL::ExecutionError, user.errors.full_messages.first
        end

        # Queue up all the email for a user when they
        # confirm their account
        OnboardingMailerService.enqueue(user)

        user
      end
    end
  end
end
