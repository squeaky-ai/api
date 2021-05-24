# frozen_string_literal: true

module Types
  # The paginated response for the event items
  # that are fetched from Dynamo
  class EventType < Types::BaseObject
    description 'The paginated events'

    field :items, [EventItemType, { null: true }], null: false
    field :pagination, PaginationType, null: false
  end
end
