# frozen_string_literal: true

module Exceptions
  class TeamNotFound < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.team_not_found'))
      super
    end
  end
end
