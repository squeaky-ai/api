# frozen_string_literal: true

module Mutations
  module Sites
    class CssSelectorBlacklistUpdate < SiteMutation
      null false

      graphql_name 'SitesCssSelectorBlacklistUpdate'

      argument :site_id, ID, required: true
      argument :selectors, [String], required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(selectors:, **_rest)
        @site.update(css_selector_blacklist: selectors.uniq)

        @site
      end
    end
  end
end
