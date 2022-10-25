# frozen_string_literal: true

module Resolvers
  module Admin
    class UsersPartners < Resolvers::Base
      type [Types::Admin::User, { null: false }], null: false

      SQUEAKY_SITE_ID = 82

      def resolve_with_timings
        users = Partner.includes(:user).map(&:user)

        map_visitors_to_users(users)
      end

      private

      def map_visitors_to_users(users)
        visitors = visitors_from_user_ids(users.map(&:id))

        users.map do |u|
          u.visitor = visitors.find { |v| v.external_attributes['id'] == u.id.to_s }
          u
        end
      end

      def visitors_from_user_ids(user_ids)
        Visitor
          .where(
            "site_id = ? AND external_attributes->>'id'::text IN (?)",
            Rails.application.config.squeaky_site_id,
            user_ids.map(&:to_s)
          )
      end
    end
  end
end
