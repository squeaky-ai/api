# frozen_string_literal: true

module Errors
  class TeamInviteExpired < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.invite_expired'))
      super
    end
  end
end
