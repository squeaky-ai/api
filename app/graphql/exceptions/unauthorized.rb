# typed: false
# frozen_string_literal: true

module Exceptions
  class Unauthorized < GraphQL::ExecutionError
    def initialize(msg = I18n.t('auth.validation.unauthorized'))
      super
    end
  end
end
