# frozen_string_literal: true

module Errors
  class Unauthorized < GraphQL::ExecutionError
    def initialize(msg = I18n.t('auth.validation.unauthorized'))
      super
    end
  end
end
