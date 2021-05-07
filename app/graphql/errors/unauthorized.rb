# frozen_string_literal: true

module Errors
  # Raise when the users auth token is either missing,
  # expired or the user no longer exists
  class Unauthorized < GraphQL::ExecutionError
    def initialize(msg = I18n.t('auth.validation.unauthorized'))
      super
    end
  end
end
