# frozen_string_literal: true

module Errors
  # Raise when a user attempts to accept an invite
  # that is no longer valid
  class TeamInviteInvalid < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.invite_invalid'))
      super
    end
  end
end
