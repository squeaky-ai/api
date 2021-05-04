# frozen_string_literal: true

module Errors
  class UserAccountNotExists < GraphQL::ExecutionError
    def initialize(msg = 'User account does not exist')
      super
    end
  end
end
