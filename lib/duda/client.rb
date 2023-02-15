# frozen_string_literal: true

module Duda
  class Client
    class << self
      def authorization_header
        "Basic #{Base64.encode64("#{ENV.fetch('DUDA_USERNAME')}:#{ENV.fetch('DUDA_PASSWORD')}")}"
      end

      def app_uuid
        ENV.fetch('DUDA_APP_UUID')
      end
    end

    def initialize(api_endpoint:)
      @api_endpoint = api_endpoint
    end

    attr_reader :api_endpoint

    # TODO: Move all the HTTP requests into here

    def refresh_access_token(refresh_token:)
      response = HTTParty.post(
        "#{api_endpoint}/integrationhub/application/#{Duda::Client.app_uuid}/token/refresh",
        timeout: 5,
        headers: {
          Authorization: Duda::Client.authorization_header
        },
        body: { 'refreshToken' => refresh_token }.to_json
      )

      if response.code != 200
        Rails.logger.error("Failed to refresh duda access with refresh token: #{refresh_token}} - #{response.body}")
        raise HTTParty::Error, 'Failed to refresh duda access token'
      end

      JSON.parse(response.body)
    end
  end
end
