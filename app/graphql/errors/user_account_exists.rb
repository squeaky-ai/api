# frozen_string_literal: true

module Errors
  class UserAccountExists < GraphQL::ExecutionError
    def initialize(msg = 'User account already exists')
      super
    end
  end
end
