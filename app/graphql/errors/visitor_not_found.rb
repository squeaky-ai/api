# frozen_string_literal: true

module Errors
  # Raise when the user tries to modify parts of the
  # visitor and they provide an invalid id
  class VisitorNotFound < GraphQL::ExecutionError
    def initialize(msg = I18n.t('site.validation.visitor_not_found'))
      super
    end
  end
end
