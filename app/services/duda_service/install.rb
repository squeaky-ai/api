# frozen_string_literal: true

module DudaService
  class Install
    def initialize(
      account_owner_uuid:,
      site_name:,
      api_endpoint:
    )
      @account_owner_uuid = account_owner_uuid
      @site_name = site_name
      @api_endpoint = api_endpoint
    end

    def install_all!
      create_site!
      create_user!
    end

    private

    attr_reader :site, :account_owner_uuid, :site_name, :api_endpoint, :auth

    def create_site!
      @site = ::Site.create!(
        name: duda_site.name,
        url: duda_site.domain,
        uuid: duda_site.uuid,
        site_type: ::Site::WEBSITE,
        provider: 'duda'
      )
    end

    def create_user!
      user = ::User.new(
        first_name: duda_user.first_name,
        last_name: duda_user.last_name,
        email: duda_user.email,
        provider: 'duda',
        provider_uuid: account_owner_uuid,
        password: Devise.friendly_token.first(10)
      )

      user.skip_confirmation_notification!
      user.confirm
      user.save!

      Team.create!(
        site:,
        user:,
        role: Team::OWNER,
        status: Team::ACCEPTED,
        linked_data_visible: true
      )
    end

    def duda_site
      @duda_site ||= DudaService::Site.new(site_name:, api_endpoint:)
    end

    def duda_user
      @duda_user ||= DudaService::User.new(account_name: duda_site.account_name, api_endpoint:)
    end
  end
end
