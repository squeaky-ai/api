# frozen_string_literal: true

module Errors
  # Raise when the user tries to change a role to
  # one that does not exist, i.e. not between
  # 0<>2
  class TeamRoleInvalid < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.team_role_invalid'))
      super
    end
  end
end
