# frozen_string_literal: true

module Mutations
  module Sites
    class DomainBlacklistDelete < SiteMutation
      null false

      graphql_name 'SitesDomainBlacklistDelete'

      argument :site_id, ID, required: true
      argument :value, String, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(value:)
        site.domain_blacklist = site.domain_blacklist.reject { |b| b['value'] == value }
        site.save

        SiteService.delete_cache(user, site)

        site
      end
    end
  end
end
