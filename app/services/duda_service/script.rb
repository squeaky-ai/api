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
      JSON.parse(response.body)
    rescue HTTParty::Error => e
      Rails.logger.error("Failed to get response from Duda API - #{e}")
      raise
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
        'Cache-Control' => 'no-cache',
        'Authorization' => "Basic #{Base64.encode64("#{ENV.fetch('DUDA_USERNAME')}:#{ENV.fetch('DUDA_PASSWORD')}")}",
        'X-DUDA-ACCESS-TOKEN' => "Bearer #{auth['authorization_code']}"
      }
    end
  end
end
