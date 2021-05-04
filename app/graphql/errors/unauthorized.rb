# frozen_string_literal: true

module Errors
  class Unauthorized < GraphQL::ExecutionError
    def initialize(msg = 'Unauthorized')
      super
    end
  end
end
