# frozen_string_literal: true

module Auth
  class PasswordsController < Devise::PasswordsController
    clear_respond_to
    respond_to :json
  end
end
