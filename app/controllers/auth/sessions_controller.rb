# frozen_string_literal: true

module Auth
  class SessionsController < Devise::SessionsController
    clear_respond_to
    respond_to :json
  end
end
