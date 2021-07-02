# frozen_string_literal: true

module Types
  class EventPaginationType < Types::BaseObject
    description 'Pagination for event objects'

    field :cursor, String, null: true
    field :has_next, Boolean, null: false
  end
end
