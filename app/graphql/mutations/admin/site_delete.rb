# frozen_string_literal: true

module Mutations
  module Admin
    class SiteDelete < AdminMutation
      null true

      graphql_name 'AdminSiteDelete'

      argument :id, ID, required: true

      type Types::Admin::Site

      def resolve(id:)
        site = Site.find(id)

        if site
          site.destroy_all_recordings!
          site.destroy
        end

        nil
      end
    end
  end
end
