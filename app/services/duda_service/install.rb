# frozen_string_literal: true

module DudaService
  class Install
    def initialize(
      account_owner_uuid:,
      installer_account_uuid:,
      site_name:,
      api_endpoint:
    )
      @account_owner_uuid = account_owner_uuid
      @installer_account_uuid = installer_account_uuid
      @site_name = site_name
      @api_endpoint = api_endpoint
    end

    def install_all!
      create_site!
      create_users!
    end

    private

    attr_reader :site, :account_owner_uuid, :installer_account_uuid, :site_name, :api_endpoint, :auth

    def create_site!
      @site = ::Site.create!(
        name: duda_site_service.name,
        url: duda_site_service.domain,
        uuid: duda_site_service.uuid,
        site_type: ::Site::WEBSITE,
        provider: 'duda'
      )
    end

    def create_users!
      create_user!(account_owner_uuid, Team::OWNER)
      create_user!(installer_account_uuid, Team::ADMIN) unless account_owner_uuid == installer_account_uuid
    end

    def create_user!(uuid, role)
      user = User.create!(
        email: "#{uuid}@duda.com",
        provider: 'duda',
        provider_uuid: uuid,
        password: Devise.friendly_token.first(10)
      )

      user.confirm

      Team.create!(
        role:,
        user:,
        site:,
        status: Team::ACCEPTED,
        linked_data_visible: role == Team::ADMIN
      )
    end

    def duda_site_service
      @duda_site_service ||= DudaService::Site.new(site_name:, api_endpoint:)
    end
  end
end
