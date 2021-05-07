# frozen_string_literal: true

module Errors
  # Raise when the authentication token that was
  # send to the user does not match the one we 
  # have stored
  class AuthInvalid < GraphQL::ExecutionError
    def initialize(msg = I18n.t('auth.validation.token_invalid'))
      super
    end
  end
end
