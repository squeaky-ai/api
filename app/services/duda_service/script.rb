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
      Rails.logger.info "Making Duda site request to #{request_url} with options #{headers}"
      response = HTTParty.post(request_url, body:, headers:, timeout:)

      if response.code != 200
        Rails.logger.error("Failed to inject script for #{site_name} - #{response.body}")
        raise HTTParty::Error, 'Failed to inject duda script'
      end

      nil
    end

    private

    attr_reader :site, :site_name, :api_endpoint, :auth

    def request_url
      "#{api_endpoint}/api/integrationhub/application/site/#{site_name}/sitewidehtml"
    end

    def body
      { markup: site.tracking_code }.to_json
    end

    def timeout
      5
    end

    def headers
      {
        'Content-Type' => 'application/json',
        'Cache-Control' => 'no-cache',
        'Authorization' => "Basic #{Base64.encode64("#{ENV.fetch('DUDA_USERNAME')}:#{ENV.fetch('DUDA_PASSWORD')}")}",
        'X-DUDA-ACCESS-TOKEN' => "Bearer #{auth['authorization_code']}"
      }
    end
  end
end
