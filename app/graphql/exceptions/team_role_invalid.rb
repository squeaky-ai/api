# typed: false
# frozen_string_literal: true

module Exceptions
  class TeamRoleInvalid < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.team_role_invalid'))
      super
    end
  end
end
