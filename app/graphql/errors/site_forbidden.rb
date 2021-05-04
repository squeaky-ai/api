# frozen_string_literal: true

module Errors
  class SiteForbidden < GraphQL::ExecutionError
    def initialize(msg = 'You lack the required permissions to do this')
      super
    end
  end
end
