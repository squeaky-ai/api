# frozen_string_literal: true

module DudaService
  class Install
    def initialize(
      account_owner_uuid:,
      site_name:,
      api_endpoint:,
      auth:,
      plan_uuid:
    )
      @account_owner_uuid = account_owner_uuid
      @site_name = site_name
      @api_endpoint = api_endpoint
      @auth = auth
      @plan_uuid = plan_uuid
    end

    def install_all!
      ActiveRecord::Base.transaction do
        create_site!
        create_plan!
        create_user!
        create_team!
        create_auth!
        inject_script!
      end

      fire_squeaky_events
      site.plan.start_free_trial!
    end

    private

    attr_reader :site, :user, :account_owner_uuid, :site_name, :api_endpoint, :auth, :plan_uuid

    def create_site!
      @site = ::Site.create!(
        name: duda_site.name,
        url: duda_site.domain,
        uuid: duda_site.uuid,
        site_type: ::Site::WEBSITE,
        provider: 'duda',
        verified_at: Time.now
      )
    end

    def create_plan!
      plan = Plans.find_by_provider('duda', plan_uuid)
      site.plan.update(plan_id: plan[:id]) if plan
    end

    def create_user!
      @user = ::User.where(email: duda_owner.email).first_or_initialize(
        first_name: duda_owner.first_name,
        last_name: duda_owner.last_name,
        email: duda_owner.email,
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
        provider_uuid: site_name,
        auth_type: 'bearer',
        access_token: auth['authorization_code'],
        refresh_token: auth['refresh_token'],
        api_endpoint:,
        expires_at: auth['expiration_date'],
        deep_link_url: duda_site.deep_link_domain
      )
    end

    def inject_script!
      duda_script.inject_script!
    end

    def duda_site
      @duda_site ||= DudaService::Site.new(site_name:, api_endpoint:, auth:)
    end

    def duda_owner
      @duda_owner ||= DudaService::Owner.new(site_name:, api_endpoint:, auth:)
    end

    def duda_script
      @duda_script ||= DudaService::Script.new(site:, site_name:, api_endpoint:, auth:)
    end

    def fire_squeaky_events
      EventTrackingJob.perform_later(
        name: 'SiteCreated',
        user_id: user.id,
        data: {
          name: site.name,
          created_at: site.created_at.iso8601,
          provider: site.provider
        }
      )

      # Don't fire it more than once for this user
      return unless user.new_record?

      EventTrackingJob.perform_later(
        name: 'UserCreated',
        user_id: user.id,
        data: {
          name: user.full_name,
          provider: user.provider
        }
      )
    end
  end
end
