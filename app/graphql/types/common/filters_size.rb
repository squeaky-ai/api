# typed: false
# frozen_string_literal: true

module Types
  module Common
    class FiltersSize < Types::BaseEnum
      graphql_name 'FiltersSize'

      value 'GreaterThan', 'Show recordings that have a duration longer than'
      value 'LessThan', 'Show recordings that have a duration shorter than'
    end
  end
end
