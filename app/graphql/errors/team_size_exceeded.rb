# frozen_string_literal: true

module Errors
  # Raise when a user attempts to invite someone but they
  # have exceeded their plan's limit
  class TeamSizeExceeded < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.size_exceeded'))
      super
    end
  end
end
