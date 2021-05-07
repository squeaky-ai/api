# frozen_string_literal: true

module Errors
  # Raise when a mutation tries to happen against a team
  # member that does not exist
  class TeamNotFound < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.team_not_found'))
      super
    end
  end
end
