# frozen_string_literal: true

module Types
  class EventType < Types::BaseObject
    description 'The paginated events'

    field :items, [EventItemType, { null: true }], null: false
    field :pagination, PaginationType, null: false
  end
end
