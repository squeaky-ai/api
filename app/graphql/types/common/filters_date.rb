# typed: false
# frozen_string_literal: true

module Types
  module Common
    class FiltersDate < BaseInputObject
      graphql_name 'FiltersDate'

      argument :from_date, GraphQL::Types::ISO8601Date, required: false
      argument :to_date, GraphQL::Types::ISO8601Date, required: false
    end
  end
end
