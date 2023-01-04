# frozen_string_literal: true

module DudaService
  class Site
    def initialize(site_name:, api_endpoint:, auth:)
      @site_name = site_name
      @api_endpoint = api_endpoint
      @auth = auth
      @site = site_response_body
    rescue HTTParty::Error => e
      Rails.logger.error("Failed to get response from Duda API - #{e}")
      raise
    end

    def name
      site['site_business_info']['business_name'] || 'Unkown'
    end

    def domain
      site['site_domain'] || site['site_default_domain']
    end

    def uuid
      site['site_name']
    end

    def account_name
      site['account_name']
    end

    private

    attr_reader :site, :site_name, :api_endpoint, :auth

    def request_url
      "#{api_endpoint}/api/integrationhub/application/site/#{site_name}"
    end

    def headers
      {
        'Authorization' => "Basic #{Base64.encode64("#{ENV.fetch('DUDA_USERNAME')}:#{ENV.fetch('DUDA_PASSWORD')}")}",
        'X-DUDA-ACCESS-TOKEN' => "Bearer #{auth['authorization_code']}"
      }
    end

    def timeout
      5
    end

    def site_response_body
      Rails.logger.info "Making Duda site request to #{request_url} with options #{headers}"
      response = HTTParty.get(request_url, headers:, timeout:)
      JSON.parse(response.body)
    end
  end
end
