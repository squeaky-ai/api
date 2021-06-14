# frozen_string_literal: true

module Auth
  # Extend the devise session controller to ensure that
  # it only responds to json
  class SessionsController < Devise::SessionsController
    clear_respond_to
    respond_to :json

    def current
      return render nothing: true, status: :unauthorized unless user_signed_in?

      render json: current_user.serialize
    end

    private

    def respond_with(resource, _opts = {})
      render json: resource
    end

    def respond_to_on_destroy
      head :no_content
    end

    def flash
      {}
    end
  end
end
