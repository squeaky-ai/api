# frozen_string_literal: true

module Mutations
  module Sites
    class RoutesDelete < SiteMutation
      null false

      graphql_name 'SitesRoutesDelete'

      argument :site_id, ID, required: true
      argument :route, String, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(route:)
        site.routes = site.routes.reject { |r| r == route }
        site.save

        SiteService.delete_cache(user, site)

        site
      end
    end
  end
end
