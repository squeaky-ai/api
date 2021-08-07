# frozen_string_literal: true

module Types
  class VisitorPagePaginationType < Types::BaseObject
    description 'Pagination for pages objects'

    field :page_size, Integer, null: false
    field :total, Integer, null: false
    field :sort, VisitorPagesSortType, null: false
  end
end
