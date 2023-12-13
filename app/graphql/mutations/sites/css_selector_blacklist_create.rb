# frozen_string_literal: true

module Mutations
  module Sites
    class CssSelectorBlacklistCreate < SiteMutation
      null false

      graphql_name 'SitesCssSelectorBlacklistCreate'

      argument :site_id, ID, required: true
      argument :selector, String, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(selector:)
        selectors = site.css_selector_blacklist
        selectors.push(selector)

        site.update(css_selector_blacklist: selectors.uniq)

        SiteService.delete_cache(user, site)

        site
      end
    end
  end
end
