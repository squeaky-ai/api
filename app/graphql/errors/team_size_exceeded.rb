# frozen_string_literal: true

module Errors
  class TeamSizeExceeded < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.size_exceeded'))
      super
    end
  end
end
