# frozen_string_literal: true

module Auth
  class ConfirmationsController < Devise::ConfirmationsController
    clear_respond_to
    respond_to :json
  end
end
