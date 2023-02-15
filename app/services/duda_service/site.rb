# frozen_string_literal: true

module DudaService
  class Site
    def initialize(site_name:, api_endpoint:, auth:)
      @site_name = site_name
      @api_endpoint = api_endpoint
      @auth = auth
      @site = duda_client.fetch_site(site_name:)
      @branding = duda_client.fetch_site_branding(site_name:)
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

    def duda_client
      @duda_client ||= Duda::Client.new(api_endpoint:, access_token: auth['authorization_code'])
    end
  end
end
