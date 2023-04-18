# typed: false
# frozen_string_literal: true

module Exceptions
  class SiteInvalidUri < GraphQL::ExecutionError
    def initialize(msg = I18n.t('site.validation.uri_invalid'))
      super
    end
  end
end
