# frozen_string_literal: true

module Mutations
  module Admin
    class UserPartnerCreate < AdminMutation
      null true

      graphql_name 'AdminUserPartnerCreate'

      argument :id, ID, required: true
      argument :name, String, required: true
      argument :slug, String, required: true

      type Types::Admin::User

      def resolve_with_timings(id:, name:, slug:)
        user = User.find(id)

        unless user.partner
          partner = Partner.create(name:, slug:, user:)
          raise GraphQL::ExecutionError, partner.errors.full_messages.first unless partner.valid?
        end

        user
      end
    end
  end
end
