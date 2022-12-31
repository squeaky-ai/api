# frozen_string_literal: true

module Integrations
  class DudaController < ApplicationController
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
      render json: { status: 'OK' }
    end

    def sso
      Rails.logger.info "Authing Duda application with: #{sso_params.to_json}"

      raise ActionController::BadRequest unless duda_auth_service.valid?

      user = duda_auth_service.fetch_user
      sign_in(:user, user)

      redirect_to "https://squeaky.ai/app/sites/#{user.sites.first.id}/dashboard", allow_other_host: true
    end

    def webhook
      render json: { status: 'OK' }
    end

    private

    def sso_params
      params.permit(:sdk_url, :timestamp, :secure_sig, :site_name, :current_user_uuid)
    end

    def install_params
      auth_params = %i[authorization_code expiration_date refresh_token type]
      params.permit(:account_owner_uuid, :installer_account_uuid, :site_name, :api_endpoint, auth: auth_params)
    end

    def uninstall_params
      params.permit(:site_name)
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
        auth: install_params['auth']
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
  end
end
