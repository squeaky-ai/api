# frozen_string_literal: true

module Types
  module Visitors
    class Pages < Types::BaseObject
      field :items, [VisitorPageType, { null: true }], null: false
      field :pagination, VisitorPagePaginationType, null: false
    end
  end
end
