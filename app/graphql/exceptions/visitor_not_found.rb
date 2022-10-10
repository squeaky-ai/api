# frozen_string_literal: true

module Exceptions
  class VisitorNotFound < GraphQL::ExecutionError
    def initialize(msg = I18n.t('site.validation.visitor_not_found'))
      super
    end
  end
end
