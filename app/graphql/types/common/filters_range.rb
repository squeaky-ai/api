# frozen_string_literal: true

module Types
  module Common
    class FiltersRange < Types::BaseEnum
      graphql_name 'FiltersRange'

      value 'From', 'Show results are longer than this time'
      value 'Between', 'Show results that fit within this time'
      value 'GreaterThan', 'Show results that are greater than this time'
      value 'LessThan', 'Show results that are less than this time'
    end
  end
end
