# frozen_string_literal: true

module Types
  module Visitors
    class Highlights < Types::BaseObject
      graphql_name 'VisitorsHighlights'

      field :active, [Types::Visitors::Visitor, { null: false }], null: false
      field :newest, [Types::Visitors::Visitor, { null: false }], null: false
    end
  end
end
