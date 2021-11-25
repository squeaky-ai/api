# frozen_string_literal: true

require 'uri'
require 'net/http'

module Mutations
  module Sites
    class Verify < SiteMutation
      null false

      graphql_name 'SitesVerifyInput'

      argument :site_id, ID, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(**_args)
        # The user may want to validate more than once
        # so we store a timestamp rather than a boolean
        script_tag_exists? ? @site.verify! : @site.unverify!

        @site
      end

      private

      def script_tag_exists?
        uri = URI(@site.url)
        res = Net::HTTP.get(uri, { 'User-Agent': 'Squeaky.ai (verification check)' })

        res.include?(@site.uuid)
      rescue StandardError
        false
      end
    end
  end
end
