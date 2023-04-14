# typed: false
# frozen_string_literal: true

module Types
  module Common
    class FiltersVisitorType < Types::BaseEnum
      graphql_name 'FiltersVisitorType'

      value 'New', 'Show results where the visitor was new'
      value 'Existing', 'Show results where the visitor was returning'
    end
  end
end
