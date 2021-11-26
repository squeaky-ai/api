# frozen_string_literal: true

module Errors
  class TeamExists < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.team_exists'))
      super
    end
  end
end
