# frozen_string_literal: true

module Errors
  # Raise when the user incorrectly fills the auth
  # out
  class BackoffExceeded < GraphQL::ExecutionError
    def initialize(msg = I18n.t('auth.validation.backoff_exceeded'))
      super
    end
  end
end
