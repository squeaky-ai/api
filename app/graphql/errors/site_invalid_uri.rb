# frozen_string_literal: true

module Errors
  # Raise when the uri provided by the user can't
  # be parsed. This step is important as the column
  # is unique and will be used in the origin check
  # when visitors connect
  class SiteInvalidUri < GraphQL::ExecutionError
    def initialize(msg = I18n.t('site.validation.uri_invalid'))
      super
    end
  end
end
