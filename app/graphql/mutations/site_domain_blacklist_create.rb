# frozen_string_literal: true

module Mutations
  # Create a new domain blacklist entry
  class SiteDomainBlacklistCreate < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :type, String, required: true
    argument :value, String, required: true

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN]
    end

    def resolve(type:, value:, **_rest)
      @site.domain_blacklist << { type: type, value: value }
      @site.save

      @site
    end
  end
end
