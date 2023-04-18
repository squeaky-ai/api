# frozen_string_literal: true

module Mutations
  module Auth
    class Signup < BaseMutation
      null true

      graphql_name 'AuthSignUp'

      argument :email, String, required: true
      argument :password, String, required: true

      type Types::Users::User

      def resolve_with_timings(email:, password:)
        user = User.new(email:, password:)

        user.save

        unless user.errors.empty?
          Rails.logger.warn "Failed to create user #{email}"
          raise GraphQL::ExecutionError, user.errors.full_messages.first
        end

        user
      end
    end
  end
end
