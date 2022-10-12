# frozen_string_literal: true

module Resolvers
  module Admin
    class User < Resolvers::Base
      type Types::Admin::User, null: true

      argument :user_id, ID, required: true

      def resolve_with_timings(user_id:)
        user = ::User.find_by(id: user_id)

        user.visitor = visitor_for_user(user) if user

        user
      end

      private

      def visitor_for_user(user)
        Visitor.find_by(
          "site_id = ? AND external_attributes->>'id'::text = ?",
          Rails.application.config.squeaky_site_id,
          user.id.to_s
        )
      end
    end
  end
end
