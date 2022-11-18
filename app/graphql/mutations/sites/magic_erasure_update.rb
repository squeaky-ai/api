# frozen_string_literal: true

module Mutations
  module Sites
    class MagicErasureUpdate < SiteMutation
      null false

      graphql_name 'SitesMagicErasureUpdate'

      argument :site_id, ID, required: true
      argument :enabled, Boolean, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(enabled:, **_rest)
        @site.update(magic_erasure_enabled: enabled)

        SiteService.delete_cache(@user, @site.id)

        @site
      end
    end
  end
end
