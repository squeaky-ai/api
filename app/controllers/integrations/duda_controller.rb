# frozen_string_literal: true

module Integrations
  class DudaController < ApplicationController
    include ActionController::Cookies

    after_action :set_same_site_cookie_value

    def install
      Rails.logger.info "Installing Duda application with: #{install_params.to_json}"

      duda_install_service.install_all!
      render json: { status: 'OK' }
    end

    def uninstall
      Rails.logger.info "Uninstalling Duda application with: #{uninstall_params.to_json}"

      duda_uninstall_service.uninstall!
      render json: { status: 'OK' }
    end

    def change_plan
      Rails.logger.info "Changing Duda plan with: #{change_plan_params.to_json}"

      site = ::Site.find_by!(uuid: change_plan_params['site_name'])
      plan = Plans.find_by_provider('duda', change_plan_params['app_plan_uuid'])

      if plan
        site.plan.change_plan!(plan[:id])
        SiteMailer.business_plan_features(site).deliver_now if Plans.business_plan?(plan)
      else
        Rails.logger.error "No matching plan: #{change_plan_params}"
      end

      render json: { status: 'OK' }
    end

    def sso
      Rails.logger.info "Authing Duda application with: #{sso_params.to_json}"

      raise ActionController::BadRequest unless duda_auth_service.valid?

      user = duda_auth_service.fetch_user
      first_time_user = user.sign_in_count.zero?

      sign_in(:user, user)

      set_provider_cookie

      # Weirdly this comes from the SSO and not the install
      duda_auth_service.store_sdk_url!

      squeaky_dashboard_url = "#{Rails.application.config.app_host}/sites/#{duda_auth_service.site.id}/dashboard/"
      squeaky_dashboard_url += '?free_trial_began=1' if first_time_user

      redirect_to squeaky_dashboard_url, allow_other_host: true
    end

    def webhook
      Rails.logger.info "Processing Duda webhook with: #{webhook_params.to_json}"

      duda_webhook_service.process!

      render json: { status: 'OK' }
    end

    private

    def sso_params
      params.permit(:sdk_url, :timestamp, :secure_sig, :site_name, :current_user_uuid)
    end

    def change_plan_params
      params.permit(:app_plan_uuid, :site_name)
    end

    def install_params
      auth_params = %i[authorization_code expiration_date refresh_token type]
      params.permit(:account_owner_uuid, :installer_account_uuid, :site_name, :api_endpoint, :app_plan_uuid, auth: auth_params)
    end

    def uninstall_params
      params.permit(:site_name)
    end

    def webhook_params
      data_params = %i[domain sub_domain]
      resource_data_params = %i[site_name]
      params.permit(:event_type, data: data_params, resource_data: resource_data_params)
    end

    def duda_auth_service
      @duda_auth_service ||= DudaService::Auth.new(
        sdk_url: sso_params['sdk_url'],
        secure_sig: sso_params['secure_sig'],
        site_name: sso_params['site_name'],
        timestamp: sso_params['timestamp'].to_i,
        current_user_uuid: sso_params['current_user_uuid']
      )
    end

    def duda_install_service
      @duda_install_service ||= DudaService::Install.new(
        account_owner_uuid: install_params['account_owner_uuid'],
        site_name: install_params['site_name'],
        api_endpoint: install_params['api_endpoint'],
        auth: install_params['auth'],
        plan_uuid: install_params['app_plan_uuid']
      )
    end

    def duda_webhook_service
      @duda_webhook_service ||= DudaService::Webhook.new(
        event_type: webhook_params['event_type'],
        data: webhook_params['data'].to_h,
        resource_data: webhook_params['resource_data'].to_h
      )
    end

    def duda_uninstall_service
      @duda_uninstall_service ||= DudaService::Uninstall.new(
        site_name: uninstall_params['site_name']
      )
    end

    def set_same_site_cookie_value
      # This is running in an iframe so must be set this way
      request.session_options[:secure] = true
      request.session_options[:same_site] = 'None'
    end

    def set_provider_cookie
      cookies[:provider] = 'duda'
    end
  end
end
