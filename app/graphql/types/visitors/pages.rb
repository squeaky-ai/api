# frozen_string_literal: true

module Types
  module Visitors
    class Pages < Types::BaseObject
      graphql_name 'VisitorsPages'

      field :items, [Types::Visitors::Page, { null: true }], null: false
      field :pagination, Types::Visitors::PagePagination, null: false
    end
  end
end
