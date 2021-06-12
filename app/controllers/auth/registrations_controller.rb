# frozen_string_literal: true

module Auth
  class RegistrationsController < Devise::RegistrationsController
    clear_respond_to
    respond_to :json
  end
end
