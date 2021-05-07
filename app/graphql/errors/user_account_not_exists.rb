# frozen_string_literal: true

module Errors
  # Raise when the user tries to log in with an
  # account that does not exist
  class UserAccountNotExists < GraphQL::ExecutionError
    def initialize(msg = I18n.t('user.validation.account_not_exists'))
      super
    end
  end
end
