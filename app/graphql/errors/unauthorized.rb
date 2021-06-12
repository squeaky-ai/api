# frozen_string_literal: true

module Errors
  # Raise when the users session has expired or they
  # no longer exist
  class Unauthorized < GraphQL::ExecutionError
    def initialize(msg = I18n.t('auth.validation.unauthorized'))
      super
    end
  end
end
