# frozen_string_literal: true

module Types
  class EventPaginationType < Types::BaseObject
    description 'Pagination for event objects'

    field :page_size, Integer, null: false
    field :page_count, Integer, null: false
    field :total, Integer, null: false
  end
end
