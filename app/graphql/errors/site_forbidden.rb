# frozen_string_literal: true

module Errors
  # Raise when the user attempts to do something
  # they don't have permission to do. Users who
  # are only members can't modify anything
  class SiteForbidden < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.forbidden'))
      super
    end
  end
end
