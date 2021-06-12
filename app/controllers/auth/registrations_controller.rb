# frozen_string_literal: true

module Auth
  # Extend the devise registration controller to ensure that
  # it only responds to json
  class RegistrationsController < Devise::RegistrationsController
    clear_respond_to
    respond_to :json
  end
end
