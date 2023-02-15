# frozen_string_literal: true

module DudaService
  class Script
    def initialize(site:, site_name:, api_endpoint:, auth:)
      @site = site
      @site_name = site_name
      @api_endpoint = api_endpoint
      @auth = auth
    end

    def inject_script!
      Duda::Client.new(api_endpoint:).inject_script(site_name:, tracking_code: site.tracking_code)
      nil
    end

    private

    attr_reader :site, :site_name, :api_endpoint, :auth
  end
end
