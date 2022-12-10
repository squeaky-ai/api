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
        name: duda_site_service.name,
        url: duda_site_service.domain,
        uuid: duda_site_service.uuid,
        site_type: ::Site::WEBSITE,
        provider: 'duda'
      )
    end

    def create_user!
      user = User.new(
        email: duda_site_service.account_email,
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

    def duda_site_service
      @duda_site_service ||= DudaService::Site.new(site_name:, api_endpoint:)
    end
  end
end
