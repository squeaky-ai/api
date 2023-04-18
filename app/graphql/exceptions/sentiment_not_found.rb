# frozen_string_literal: true

module Exceptions
  class SentimentNotFound < GraphQL::ExecutionError
    def initialize(msg = 'Sentiment response not found')
      super
    end
  end
end
