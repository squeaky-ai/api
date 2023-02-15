# frozen_string_literal: true

module DudaService
  class Site
    def initialize(site_name:, api_endpoint:, auth:)
      @site_name = site_name
      @api_endpoint = api_endpoint
      @auth = auth
      @site = site_response_body
      @branding = branding_response_body
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
      "#{branding['dashboard_domain']}/home/site/#{uuid}?appstore&appId=#{Duda::Client.app_uuid}"
    end

    private

    attr_reader :site, :branding, :site_name, :api_endpoint, :auth

    def headers
      {
        'Authorization' => Duda::Client.authorization_header,
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

    def make_request(url) # rubocop:disable Metrics/AbcSize
      Rails.logger.info "Making Duda site request to #{url} with options #{headers}"
      response = HTTParty.get(url, headers:, timeout:)

      if response.code != 200
        Rails.logger.error("Failed to fetch duda site for #{site_name} - #{response.body}")
        raise HTTParty::Error, 'Failed to fetch duda site'
      end

      body = JSON.parse(response.body)
      Rails.logger.info "Got Duda site response: #{response.body} - status: #{response.code}"
      body
    end
  end
end
