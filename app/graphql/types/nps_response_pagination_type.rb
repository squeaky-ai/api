# frozen_string_literal: true

module Types
  class NpsResponsePaginationType < Types::BaseObject
    description 'Pagination for response item objects'

    field :page_size, Integer, null: false
    field :total, Integer, null: false
    field :sort, NpsResponseSortType, null: false
  end
end
