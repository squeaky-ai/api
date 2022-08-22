# frozen_string_literal: true

module Resolvers
  module Users
    class UserExists < Resolvers::Base
      type Boolean, null: false

      argument :email, String, required: true

      def resolve_with_timings(email:)
        ::User.exists?(email:)
      end
    end
  end
end
