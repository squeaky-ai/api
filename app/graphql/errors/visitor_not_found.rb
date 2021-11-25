# frozen_string_literal: true

module Errors
  class VisitorNotFound < GraphQL::ExecutionError
    def initialize(msg = I18n.t('site.validation.visitor_not_found'))
      super
    end
  end
end
