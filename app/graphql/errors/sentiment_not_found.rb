# frozen_string_literal: true

module Errors
  class SentimentNotFound < GraphQL::ExecutionError
    def initialize(msg = 'Sentiment response not found')
      super
    end
  end
end
