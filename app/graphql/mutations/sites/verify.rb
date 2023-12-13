# frozen_string_literal: true

require 'httparty'

module Mutations
  module Sites
    class Verify < SiteMutation
      null false

      graphql_name 'SitesVerify'

      argument :site_id, ID, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve
        # The user may want to validate more than once
        # so we store a timestamp rather than a boolean
        script_tag_exists? ? site.verify! : site.unverify!

        SiteService.delete_cache(user, site)

        site
      end

      private

      def script_tag_exists?
        options = {
          headers: { 'User-Agent': 'Squeaky.ai (verification check)' },
          follow_redirects: true,
          timeout: 5
        }

        response = HTTParty.get(site.url, options)

        response.body.include?(site.uuid)
      rescue StandardError => e
        Rails.logger.warn("Failed to verify site #{site.id} - #{e}")
        false
      end
    end
  end
end
