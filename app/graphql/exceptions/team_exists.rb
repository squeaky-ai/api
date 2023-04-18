# frozen_string_literal: true

module Exceptions
  class TeamExists < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.team_exists'))
      super
    end
  end
end
