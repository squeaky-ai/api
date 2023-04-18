# frozen_string_literal: true

module Exceptions
  class Forbidden < GraphQL::ExecutionError
    def initialize(msg = I18n.t('auth.validation.forbidden'))
      super
    end
  end
end
