# frozen_string_literal: true

module Resolvers
  module Users
    class User < Resolvers::Base
      type Types::Users::User, null: true

      def resolve_with_timings
        user = context[:current_user]
        user&.touch :last_activity_at # rubocop:disable Rails/SkipsModelValidations
        user
      end
    end
  end
end
