# frozen_string_literal: true

module Errors
  # Raise when a user attempts to accept an invite
  # that has expired, or has been cancelled by a
  # member of the team
  class TeamInviteExpired < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.invite_expired'))
      super
    end
  end
end
