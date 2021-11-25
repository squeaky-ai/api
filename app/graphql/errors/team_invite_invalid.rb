# frozen_string_literal: true

module Errors
  class TeamInviteInvalid < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.invite_invalid'))
      super
    end
  end
end
