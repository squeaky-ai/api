# typed: false
# frozen_string_literal: true

module Resolvers
  module Admin
    class Admin < Resolvers::Base
      type Types::Admin::Admin, null: false

      def resolve_with_timings
        raise Exceptions::Unauthorized unless context[:current_user]&.superuser?

        {}
      end
    end
  end
end
