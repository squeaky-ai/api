# frozen_string_literal: true

module Types
  class EventPaginationType < Types::BaseObject
    description 'Pagination for event objects'

    field :per_page, Integer, null: false
    field :item_count, Integer, null: false
    field :current_page, Integer, null: false
    field :total_pages, Integer, null: false
  end
end
