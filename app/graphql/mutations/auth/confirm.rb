# frozen_string_literal: true

module Mutations
  module Auth
    class Confirm < BaseMutation
      null true

      graphql_name 'AuthConfirm'

      argument :token, String, required: true

      type Types::Users::User

      def resolve_with_timings(token:)
        user = User.confirm_by_token(token)

        unless user.errors.empty?
          Rails.logger.warn "Sign up token was incorrect #{token}"
          raise GraphQL::ExecutionError, user.errors.full_messages.first
        end

        # Queue up all the email for a user when they
        # confirm their account
        OnboardingMailerService.enqueue(user)

        fire_squeaky_event(user)

        user
      end

      private

      def fire_squeaky_event(user)
        EventTrackingJob.perform_later(
          name: 'UserCreated',
          user_id: user.id,
          data: {
            name: user.full_name,
            provider: user.provider
          }
        )
      end
    end
  end
end
