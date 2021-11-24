# frozen_string_literal: true

module Types
  module Sentiment
    class ResponseSort < Types::BaseEnum
      value 'timestamp__desc', 'Most recent response first'
      value 'timestamp__asc', 'Oldest response first'
    end
  end
end
