# frozen_string_literal: true

module Auth
  class ConfirmationsController < Devise::ConfirmationsController
    # Make sure the controller only responds to json
    clear_respond_to
    respond_to :json
  end
end
