# frozen_string_literal: true

module DudaService
  class Install
    def initialize(
      account_owner_uuid:,
      site_name:,
      api_endpoint:,
      auth:
    )
      @account_owner_uuid = account_owner_uuid
      @site_name = site_name
      @api_endpoint = api_endpoint
      @auth = auth
    end

    def install_all!
      ActiveRecord::Base.transaction do
        create_site!
        create_user!
        create_team!
        create_auth!
      end
    end

    private

    attr_reader :site, :user, :account_owner_uuid, :site_name, :api_endpoint, :auth

    def create_site!
      @site = ::Site.create!(
        name: duda_site.name,
        url: duda_site.domain,
        uuid: duda_site.uuid,
        site_type: ::Site::WEBSITE,
        provider: 'duda'
      )
    end

    def create_user! # rubocop:disable Metrics/AbcSize
      @user = ::User.where(email: duda_user.email).first_or_initialize(
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
    end

    def create_team!
      Team.create!(
        site:,
        user:,
        role: Team::OWNER,
        status: Team::ACCEPTED,
        linked_data_visible: true
      )
    end

    def create_auth!
      ProviderAuth.create!(
        site:,
        provider: 'duda',
        provider_uuid: account_owner_uuid, # TODO: Should be the site uuid?
        auth_type: 'bearer',
        access_token: auth['authorization_code'],
        refresh_token: auth['refresh_token'],
        api_endpoint:,
        expires_at: auth['expiration_date']
      )
    end

    def duda_site
      @duda_site ||= DudaService::Site.new(site_name:, api_endpoint:, auth:)
    end

    def duda_user
      @duda_user ||= DudaService::User.new(account_name: duda_site.account_name, api_endpoint:)
    end
  end
end
