# frozen_string_literal: true

module Auth
  class RegistrationsController < Devise::RegistrationsController
    clear_respond_to
    respond_to :json

    def create
      build_resource(sign_up_params)

      resource.save
      render json: resource
    end
  end
end
