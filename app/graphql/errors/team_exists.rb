# frozen_string_literal: true

module Errors
  # Raise when a user attempts to invite someone that is
  # already part of the team
  class TeamExists < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.team_exists'))
      super
    end
  end
end
