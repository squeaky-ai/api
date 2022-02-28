# frozen_string_literal: true

module Mutations
  module Auth
    class PasswordReset < BaseMutation
      null true

      graphql_name 'AuthConfirmationsPasswordReset'

      argument :email, String, required: true

      type Types::Common::GenericSuccess

      def resolve(email:)
        user = User.send_reset_password_instructions({ email: })

        unless user.errors.empty?
          Rails.logger.warn "Reset password failed for #{email}"
          raise GraphQL::ExecutionError, user.errors.full_messages.first
        end

        { message: 'Password reset sent' }
      end
    end
  end
end
