# typed: false
# frozen_string_literal: true

module DudaService
  class Owner
    def initialize(site_name:, api_endpoint:, auth:)
      @site_name = site_name
      @api_endpoint = api_endpoint
      @auth = auth
      @owner = Duda::Client.new(api_endpoint:, access_token: auth['authorization_code']).fetch_owner(site_name:)
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
  end
end
