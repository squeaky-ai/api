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

    def request_options
      {
        timeout: 5,
        headers: {
          Authorization: "Basic #{Base64.encode64("#{ENV.fetch('DUDA_USERNAME')}:#{ENV.fetch('DUDA_PASSWORD')}")}"
        }
      }
    end

    def user_response_body
      response = HTTParty.get(request_url, request_options)
      JSON.parse(response.body)
    end
  end
end