# frozen_string_literal: true

module Errors
  # Raise when the user tries to sign up with an email
  # that already exists. Or when they attempt to sign
  # up accidently instead of logging in
  class UserAccountExists < GraphQL::ExecutionError
    def initialize(msg = I18n.t('user.validation.account_exists'))
      super
    end
  end
end
