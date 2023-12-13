# frozen_string_literal: true

module Mutations
  module Sites
    class DomainBlacklistCreate < SiteMutation
      null false

      graphql_name 'SitesDomainBlacklistCreate'

      argument :site_id, ID, required: true
      argument :type, String, required: true
      argument :value, String, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(type:, value:)
        site.domain_blacklist << { type:, value: }

        if type == 'domain'
          delete_visitors_by_domain(value)
        else
          delete_visitors_by_email(value)
        end

        site.save

        SiteService.delete_cache(user, site)

        site
      end

      private

      def delete_visitors_by_domain(domain)
        visitors = site.visitors.where("external_attributes->>'email' LIKE ?", "%@#{domain}")

        delete_visitors(visitors.map(&:id))
      end

      def delete_visitors_by_email(email)
        visitors = site.visitors.where("external_attributes->>'email' = ?", email)

        delete_visitors(visitors.map(&:id))
      end

      def delete_visitors(visitor_ids)
        visitor_ids.each do |id|
          visitor = Visitor.find(id)

          visitor.destroy_all_recordings!
          visitor.destroy!
        end
      end
    end
  end
end
