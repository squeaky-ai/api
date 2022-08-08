# frozen_string_literal: true

module Resolvers
  module Admin
    class Users < Resolvers::Base
      type [Types::Admin::User, { null: true }], null: false

      SQUEAKY_SITE_ID = 82

      def resolve_with_timings
        users = User.all
        user_ids = users.map(&:id)

        visitors = visitors_from_user_ids(user_ids)

        users.map do |u|
          visitor = visitors.find { |v| v.external_attributes['id'] == u.id.to_s }
          u.visitor = visitor if visitor
          u
        end
      end

      private

      def visitors_from_user_ids(user_ids)
        Visitor
          .where(
            "site_id = ? AND external_attributes->>'id'::text IN (?)",
            SQUEAKY_SITE_ID,
            user_ids.map(&:to_s)
          )
      end
    end
  end
end
