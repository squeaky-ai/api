# frozen_string_literal: true

module Resolvers
  module Admin
    class Users < Resolvers::Base
      type Types::Admin::Users, null: false

      SQUEAKY_SITE_ID = 82

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 25
      argument :search, String, required: false, default_value: nil
      argument :sort, Types::Admin::UserSort, required: false, default_value: 'created_at__desc'

      def resolve_with_timings(page:, size:, search:, sort:)
        users = ::User
                .includes(:sites)
                .page(page)
                .per(size)
                .order(order(sort))
        users = search_by(users, search)

        {
          items: map_visitors_to_users(users),
          pagination: {
            page_size: size,
            total: users.total_count,
            sort:
          }
        }
      end

      private

      def order(sort)
        sorts = {
          'created_at__asc' => 'created_at ASC',
          'created_at__desc' => 'created_at DESC',
          'last_activity_at__asc' => 'last_activity_at ASC',
          'last_activity_at__desc' => 'last_activity_at DESC',
          'name__asc' => 'first_name ASC',
          'name__desc' => 'first_name DESC'
        }
        sorts[sort]
      end

      def search_by(users, search)
        return users unless search.presence

        query = "%#{search}%"

        users.where("CONCAT(first_name, ' ', last_name) ILIKE :query OR email ILIKE :query", query:)
      end

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
