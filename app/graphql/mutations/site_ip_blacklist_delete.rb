# frozen_string_literal: true

module Mutations
  class SiteIpBlacklistDelete < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :value, String, required: true

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN]
    end

    def resolve(value:, **_rest)
      @site.ip_blacklist = @site.ip_blacklist.reject { |b| b['value'] == value }
      @site.save

      @site
    end
  end
end
