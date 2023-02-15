# frozen_string_literal: true

module DudaService
  class User
    def initialize(account_name:, api_endpoint:)
      @account_name = account_name
      @api_endpoint = api_endpoint
      @user = user_response_body
    rescue HTTParty::Error => e
      Rails.logger.error("Failed to get response from Duda API - #{e}")
      raise
    end

    def first_name
      user['first_name']
    end

    def last_name
      user['last_name']
    end

    def email
      user['email']
    end

    private

    attr_reader :user, :account_name, :api_endpoint

    def request_url
      "#{api_endpoint}/api/accounts/#{account_name}"
    end

    def timeout
      5
    end

    def headers
      {
        Authorization: "Basic #{Base64.encode64("#{ENV.fetch('DUDA_USERNAME')}:#{ENV.fetch('DUDA_PASSWORD')}")}"
      }
    end

    def user_response_body # rubocop:disable Metrics/AbcSize
      Rails.logger.info "Making Duda user request to #{request_url} with options #{headers}"
      response = HTTParty.get(request_url, headers:, timeout:)

      if response.code != 200
        Rails.logger.error("Failed to fetch duda user for #{account_name} - #{response.body}")
        raise HTTParty::Error, 'Failed to fetch duda user'
      end

      body = JSON.parse(response.body)
      Rails.logger.info "Got Duda user response: #{response.body} - status: #{response.code}"
      body
    end
  end
end
