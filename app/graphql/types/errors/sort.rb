# typed: false
# frozen_string_literal: true

module Types
  module Errors
    class Sort < Types::BaseEnum
      graphql_name 'ErrorsSort'

      value 'error_count__desc', 'Most errors first'
      value 'error_count__asc', 'Lest errors first'
      value 'recording_count__desc', 'Most recordings first'
      value 'recording_count__asc', 'Lest recordings first'
      value 'timestamp__desc', 'Most recent occurances first first'
      value 'timestamp__asc', 'Lest recent occurances first first'
    end
  end
end
