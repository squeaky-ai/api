# frozen_string_literal: true

module Exceptions
  class NpsNotFound < GraphQL::ExecutionError
    def initialize(msg = 'NPS response not found')
      super
    end
  end
end
