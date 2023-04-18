# frozen_string_literal: true

module Exceptions
  class SiteNotFound < GraphQL::ExecutionError
    def initialize(msg = I18n.t('site.validation.site_not_found'))
      super
    end
  end
end
