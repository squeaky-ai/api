# frozen_string_literal: true

module Mutations
  module Sites
    class RoutesUpdate < SiteMutation
      null false

      graphql_name 'SitesRoutesUpdate'

      argument :site_id, ID, required: true
      argument :routes, [String, { null: false }], required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(routes:, **_rest)
        @site.routes = routes
        @site.routes_will_change!
        @site.save

        SiteService.delete_cache(@user, @site.id)

        @site
      end
    end
  end
end
