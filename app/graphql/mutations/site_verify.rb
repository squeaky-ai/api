# frozen_string_literal: true

require 'uri'
require 'net/http'

module Mutations
  class SiteVerify < SiteMutation
    null false

    argument :site_id, ID, required: true

    type Types::SiteType

    def resolve(site_id:)
      # The user may want to validate more than once
      # so we store a timestamp rather than a boolean
      @site.update({ verified_at: Time.now }) if script_tag_exists?

      @site
    end

    private

    def script_tag_exists?
      uri = URI(@site.url)
      res = Net::HTTP.get(uri, { 'User-Agent': 'Squeaky.ai verification check' })

      res.include?(@site.uuid)
    end
  end
end
