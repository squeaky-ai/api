# frozen_string_literal: true

module Types
  class EventPaginationType < Types::BaseObject
    description 'Pagination for event objects'

    field :cursor, String, null: true
    field :is_last, Boolean, null: false
    field :page_size, Integer, null: false
  end
end
