# frozen_string_literal: true

module Auth
  # Extend the devise passwords controller to ensure that
  # it only responds to json
  class PasswordsController < Devise::PasswordsController
    clear_respond_to
    respond_to :json
  end
end
