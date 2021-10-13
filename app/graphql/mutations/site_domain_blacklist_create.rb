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

      if type == 'domain'
        delete_visitors_by_domain(value)
      else
        delete_visitors_by_email(value)
      end

      @site.save

      @site
    end

    private

    def delete_visitors_by_domain(domain)
      ids = @site.visitors.where("external_attributes->>'email' LIKE ?", "%@#{domain}").select(:id)
      Visitor.destroy(ids.map(&:id))
    end

    def delete_visitors_by_email(email)
      ids = @site.visitors.where("external_attributes->>'email' = ?", email).select(:id)
      Visitor.destroy(ids.map(&:id))
    end
  end
end
