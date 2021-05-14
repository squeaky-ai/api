# frozen_string_literal: true

module Errors
  # Raise when the user tries to do something they are
  # not allowed to do
  class Forbidden < GraphQL::ExecutionError
    def initialize(msg = I18n.t('auth.validation.forbidden'))
      super
    end
  end
end
