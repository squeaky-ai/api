# frozen_string_literal: true

module Mutations
  module Sites
    class IpBlacklistDelete < SiteMutation
      null false

      graphql_name 'SitesIpBlacklistDelete'

      argument :site_id, ID, required: true
      argument :value, String, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(value:)
        site.ip_blacklist = site.ip_blacklist.reject { |b| b['value'] == value }
        site.save

        SiteService.delete_cache(user, site.id)

        site
      end
    end
  end
end
