# frozen_string_literal: true

module Errors
  class SiteNotFound < GraphQL::ExecutionError
    def initialize(msg = 'Site not found')
      super
    end
  end
end
