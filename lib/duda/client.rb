# frozen_string_literal: true

module Duda
  class Client
    class << self
      def app_uuid
        ENV.fetch('DUDA_APP_UUID')
      end
    end

    def initialize(api_endpoint:, access_token: nil)
      @api_endpoint = api_endpoint
      @access_token = access_token
    end

    attr_reader :api_endpoint, :access_token

    def refresh_access_token(refresh_token:)
      response = HTTParty.post(
        "#{api_endpoint}/api/integrationhub/application/#{app_uuid}/token/refresh",
        timeout:,
        headers:,
        body: { 'refreshToken' => refresh_token }.to_json
      )

      if response.code != 200
        Rails.logger.error("Failed to refresh duda access with refresh token: #{refresh_token}} - #{response.body}")
        raise HTTParty::Error, 'Failed to refresh duda access token'
      end

      JSON.parse(response.body)
    end

    def fetch_owner(site_name:)
      response = HTTParty.get(
        "#{api_endpoint}/api/integrationhub/application/site/#{site_name}/account/details",
        timeout:,
        headers:
      )

      if response.code != 200
        Rails.logger.error("Failed to fetch duda site owner for #{site_name} - #{response.body}")
        raise HTTParty::Error, 'Failed to fetch duda site'
      end

      JSON.parse(response.body)
    end

    def fetch_site(site_name:)
      response = HTTParty.get(
        "#{api_endpoint}/api/integrationhub/application/site/#{site_name}",
        timeout:,
        headers:
      )

      if response.code != 200
        Rails.logger.error("Failed to fetch duda site for #{site_name} - #{response.body}")
        raise HTTParty::Error, 'Failed to fetch duda site'
      end

      JSON.parse(response.body)
    end

    def fetch_site_branding(site_name:)
      response = HTTParty.get(
        "#{api_endpoint}/api/integrationhub/application/site/#{site_name}/branding",
        timeout:,
        headers:
      )

      if response.code != 200
        Rails.logger.error("Failed to fetch duda site branding for #{site_name} - #{response.body}")
        raise HTTParty::Error, 'Failed to fetch duda site'
      end

      JSON.parse(response.body)
    end

    def inject_script(site_name:, tracking_code:)
      response = HTTParty.post(
        "#{api_endpoint}/api/integrationhub/application/site/#{site_name}/sitewidehtml",
        timeout:,
        headers: headers('Cache-Control' => 'no-cache'),
        body: { markup: tracking_code }.to_json
      )

      if response.code != 200
        Rails.logger.error("Failed to inject script for #{site_name} - #{response.body}")
        raise HTTParty::Error, 'Failed to inject duda script'
      end

      JSON.parse(response.body) if response.body != ''
    end

    private

    def timeout
      5
    end

    def headers(additional_headers = {})
      # All requests need this
      base_headers = {
        'Authorization' => "Basic #{Base64.encode64("#{ENV.fetch('DUDA_USERNAME')}:#{ENV.fetch('DUDA_PASSWORD')}")}",
        'Content-Type' => 'application/json',
        **additional_headers
      }

      # This is required for some
      base_headers['X-DUDA-ACCESS-TOKEN'] = "Bearer #{access_token}" if access_token

      base_headers
    end

    def app_uuid
      ENV.fetch('DUDA_APP_UUID')
    end
  end
end
