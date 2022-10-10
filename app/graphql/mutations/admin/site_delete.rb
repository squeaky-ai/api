# frozen_string_literal: true

module Mutations
  module Admin
    class SiteDelete < BaseMutation
      null true

      graphql_name 'AdminSiteDelete'

      argument :id, ID, required: true

      type Types::Admin::Site

      def resolve(id:)
        raise Exceptions::Unauthorized unless context[:current_user]&.superuser?

        site = Site.find(id)

        if site
          SiteCleanupJob.perform_later([site.id])
          site.destroy
        end

        nil
      end
    end
  end
end
