# frozen_string_literal: true

module Mutations
  module Sites
    class DomainBlacklistDelete < SiteMutation
      null false

      graphql_name 'SitesDomainBlacklistDeleteInput'

      argument :site_id, ID, required: true
      argument :value, String, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(value:, **_rest)
        @site.domain_blacklist = @site.domain_blacklist.reject { |b| b['value'] == value }
        @site.save

        @site
      end
    end
  end
end
