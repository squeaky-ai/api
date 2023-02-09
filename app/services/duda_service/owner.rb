# frozen_string_literal: true

module DudaService
  class Owner
    def initialize(site_name:, api_endpoint:, auth:)
      @site_name = site_name
      @api_endpoint = api_endpoint
      @auth = auth
      @owner = owner_response_body
    rescue HTTParty::Error => e
      Rails.logger.error("Failed to get response from Duda API - #{e}")
      raise
    end

    def first_name
      owner['first_name']
    end

    def last_name
      owner['last_name']
    end

    def email
      owner['email']
    end

    private

    attr_reader :owner, :site_name, :api_endpoint, :auth

    def request_url
      "#{api_endpoint}/api/integrationhub/application/site/#{site_name}/account/details"
    end

    def timeout
      5
    end

    def headers
      {
        Authorization: "Basic #{Base64.encode64("#{ENV.fetch('DUDA_USERNAME')}:#{ENV.fetch('DUDA_PASSWORD')}")}",
        'X-DUDA-ACCESS-TOKEN' => "Bearer #{auth['authorization_code']}"
      }
    end

    def owner_response_body
      Rails.logger.info "Making Duda owner request to #{request_url} with options #{headers}"
      response = HTTParty.get(request_url, headers:, timeout:)
      body = JSON.parse(response.body)
      Rails.logger.info "Got Duda owner response: #{response.body} - status: #{response.code}"
      body
    end
  end
end
