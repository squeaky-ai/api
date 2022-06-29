# frozen_string_literal: true

module Resolvers
  module Admin
    class Users < Resolvers::Base
      type [Types::Users::User, { null: true }], null: false

      def resolve_with_timings
        User.all
      end
    end
  end
end
