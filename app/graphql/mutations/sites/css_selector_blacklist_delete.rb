# frozen_string_literal: true

module Mutations
  module Sites
    class CssSelectorBlacklistDelete < SiteMutation
      null false

      graphql_name 'SitesCssSelectorBlacklistDelete'

      argument :site_id, ID, required: true
      argument :selector, String, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(selector:)
        selectors = site.css_selector_blacklist.reject { |s| s == selector }
        site.update(css_selector_blacklist: selectors.uniq)

        SiteService.delete_cache(user, site)

        site
      end
    end
  end
end
