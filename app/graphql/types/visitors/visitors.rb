# frozen_string_literal: true

module Types
  module Visitors
    class Visitors < Types::BaseObject
      field :items, [VisitorType, { null: true }], null: false
      field :pagination, VisitorPaginationType, null: false
    end
  end
end
