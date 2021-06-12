# frozen_string_literal: true

module Auth
  # Extend the devise session controller to ensure that
  # it only responds to json
  class SessionsController < Devise::SessionsController
    clear_respond_to
    respond_to :json

    def current
      return render nothing: true, status: :unauthorized unless user_signed_in?

      render json: current_user
    end
  end
end
