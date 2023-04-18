# typed: false
# frozen_string_literal: true

module Mutations
  module Auth
    class Reconfirm < BaseMutation
      null true

      graphql_name 'AuthReconfirm'

      argument :email, String, required: true

      type Types::Common::GenericSuccess

      def resolve_with_timings(email:)
        user = User.send_confirmation_instructions({ email: })

        unless user.errors.empty?
          Rails.logger.warn "Sign up reconfirmation failed for #{email}"
          raise GraphQL::ExecutionError, user.errors.full_messages.first
        end

        { message: 'Reconfirmation sent' }
      end
    end
  end
end
