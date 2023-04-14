# typed: false
# frozen_string_literal: true

module Types
  module Errors
    class Errors < Types::BaseObject
      graphql_name 'Errors'

      field :items, [Types::Errors::Item, { null: false }], null: false
      field :pagination, Types::Errors::Pagination, null: false
    end
  end
end
