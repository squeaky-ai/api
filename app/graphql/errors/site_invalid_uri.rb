# frozen_string_literal: true

module Errors
  class SiteInvalidUri < GraphQL::ExecutionError
    def initialize(msg = 'The provided uri is not valid')
      super
    end
  end
end
