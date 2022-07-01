# frozen_string_literal: true

module Mutations
  module Sites
    class SuperuserAccessUpdate < SiteMutation
      null false

      graphql_name 'SitesSuperuserAccessUpdate'

      argument :site_id, ID, required: true
      argument :enabled, Boolean, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(enabled:, **_rest)
        @site.update(superuser_access_enabled: enabled)

        @site
      end
    end
  end
end