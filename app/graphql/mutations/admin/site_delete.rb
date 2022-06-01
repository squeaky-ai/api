# frozen_string_literal: true

module Mutations
  module Admin
    class SiteDelete < BaseMutation
      null true

      graphql_name 'AdminSiteDelete'

      argument :id, ID, required: true

      type Types::Sites::Site

      def resolve(id:)
        raise Errors::Unauthorized unless context[:current_user]&.superuser?

        Site.find(id)&.destroy

        nil
      end
    end
  end
end
