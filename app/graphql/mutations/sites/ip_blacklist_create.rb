# frozen_string_literal: true

module Mutations
  module Sites
    class IpBlacklistCreate < SiteMutation
      null false

      graphql_name 'SitesIpBlacklistCreateInput'

      argument :site_id, ID, required: true
      argument :name, String, required: true
      argument :value, String, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(name:, value:, **_rest)
        @site.ip_blacklist << { name: name, value: value }
        @site.save

        @site
      end
    end
  end
end
