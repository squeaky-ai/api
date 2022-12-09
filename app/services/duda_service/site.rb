# frozen_string_literal: true

module DudaService
  class Site
    def initialize(site_name:, api_endpoint:)
      @site_name = site_name
      @api_endpoint = api_endpoint

      @site = HTTParty.get(request_url, request_options).body
    rescue HTTParty::Error => e
      Rails.logger.error("Failed to get response from Duda API - #{e}")
      raise
    end

    def name
      'TODO'
    end

    def domain
      site['site_default_domain']
    end

    def uuid
      site['site_name']
    end

    private

    attr_reader :site, :site_name, :api_endpoint

    def request_url
      "#{api_endpoint}/api/sites/multiscreen/#{site_name}"
    end

    def request_options
      {
        timeout: 5,
        headers: {
          Authorization: "Basic #{Base64.encode64("#{ENV.fetch('SQUEAKY_DUDA_USERNAME')}:#{ENV.fetch('SQUEAKY_DUDA_PASSWORD')}")}"
        }
      }
    end
  end
end
