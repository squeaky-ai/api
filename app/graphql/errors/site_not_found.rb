# frozen_string_literal: true

module Errors
  # Raise when the user tries to view a site that does
  # not exist. This should be raised when the site does
  # exist, but the user is not a member so we don't
  # reveal stuff
  class SiteNotFound < GraphQL::ExecutionError
    def initialize(msg = I18n.t('site.validation.site_not_found'))
      super
    end
  end
end
