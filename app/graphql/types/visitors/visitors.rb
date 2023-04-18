# frozen_string_literal: true

module Types
  module Visitors
    class Visitors < Types::BaseObject
      graphql_name 'Visitors'

      field :items, [Types::Visitors::Visitor, { null: false }], null: false
      field :pagination, Types::Visitors::Pagination, null: false
    end
  end
end
