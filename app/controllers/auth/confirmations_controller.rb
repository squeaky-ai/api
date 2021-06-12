# frozen_string_literal: true

module Auth
  # Extend the devise confirmations controller to ensure that
  # it only responds to json
  class ConfirmationsController < Devise::ConfirmationsController
    clear_respond_to
    respond_to :json
  end
end
