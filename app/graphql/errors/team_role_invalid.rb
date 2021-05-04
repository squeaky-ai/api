# frozen_string_literal: true

module Errors
  class TeamRoleInvalid < GraphQL::ExecutionError
    def initialize(msg = 'Team role is invalid')
      super
    end
  end
end
