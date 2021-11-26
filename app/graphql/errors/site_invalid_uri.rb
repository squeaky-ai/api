# frozen_string_literal: true

module Errors
  class SiteInvalidUri < GraphQL::ExecutionError
    def initialize(msg = I18n.t('site.validation.uri_invalid'))
      super
    end
  end
end
