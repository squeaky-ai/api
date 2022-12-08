# frozen_string_literal: true

module Integrations
  class DudaController < ApplicationController
    def install
      render json: { status: 'OK' }
    end

    def uninstall
      render json: { status: 'OK' }
    end

    def change_plan
      render json: { status: 'OK' }
    end

    def sso
      Rails.logger.info "Authing Duda with: #{sso_params.to_json}"

      # If auth is valid then log the user in and redirect

      render json: { status: duda_auth_service.valid? ? 'OK' : 'Not OK' }
    end

    def webhook
      render json: { status: 'OK' }
    end

    private

    def sso_params
      params.permit(:sdk_url, :timestamp, :secure_sig, :site_name, :current_user_uuid)
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
  end
end
