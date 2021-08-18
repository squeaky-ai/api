# frozen_string_literal: true

require 'uri'
require 'net/http'

module Mutations
  # Verify that the site's uuid exists somewhere on the sites
  # url. We may need stricter checks if people put the tracking
  # code in the wrong place
  class SiteVerify < SiteMutation
    null false

    argument :site_id, ID, required: true

    type Types::SiteType

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
