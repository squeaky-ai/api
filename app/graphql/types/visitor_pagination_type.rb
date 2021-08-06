# frozen_string_literal: true

module Types
  class VisitorPaginationType < Types::BaseObject
    description 'Pagination for visitor objects'

    field :page_size, Integer, null: false
    field :total, Integer, null: false
    field :sort, VisitorSortType, null: false
  end
end
