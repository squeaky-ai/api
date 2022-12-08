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
      auth = DudaService::Auth.new(**sso_params)

      # If auth is valid then log the user in and redirect

      render json: { status: auth.valid? ? 'OK' : 'Not OK' }
    end

    def webhook
      render json: { status: 'OK' }
    end
  end

  private

  def sso_params
    params.permit(:sdk_url, :timestamp, :secure_sig, :site_name, :current_user_uuid)
  end
end
