# typed: false
# frozen_string_literal: true

module Types
  module Common
    class FiltersStart < Types::BaseEnum
      graphql_name 'FiltersStart'

      value 'Before', 'Show recordings that start before this time'
      value 'After', 'Show recordings that start after this time'
    end
  end
end
