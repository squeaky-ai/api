# frozen_string_literal: true

module DudaService
  class Site
    def initialize(site_name:, api_endpoint:, auth:)
      @site_name = site_name
      @api_endpoint = api_endpoint
      @auth = auth
      @site = site_response_body
      @branding = branding_response_body
    rescue HTTParty::Error => e
      Rails.logger.error("Failed to get response from Duda API - #{e}")
      raise
    end

    def name
      url_parts = URI(domain).host.split('.')
      url_parts.pop
      url_parts.join('.')
    end

    def domain
      "https://#{site['site_domain'].presence || site['site_default_domain'].presence}"
    end

    def uuid
      site['site_name']
    end

    def account_name
      site['account_name']
    end

    def deep_link_domain
      "#{branding['dashboard_domain']}/home/site/#{uuid}?appstore&appId=#{ENV.fetch('DUDA_APP_UUID')}"
    end

    private

    attr_reader :site, :branding, :site_name, :api_endpoint, :auth

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
      make_request("#{api_endpoint}/api/integrationhub/application/site/#{site_name}")
    end

    def branding_response_body
      make_request("#{api_endpoint}/api/integrationhub/application/site/#{site_name}/branding")
    end

    def make_request(url)
      Rails.logger.info "Making Duda site request to #{url} with options #{headers}"
      response = HTTParty.get(url, headers:, timeout:)
      body = JSON.parse(response.body)
      Rails.logger.info "Got Duda site response: #{response.body}"
      body
    end
  end
end
