# frozen_string_literal: true

module Types
  # The paginated response for the event items
  # that are fetched from Dynamo
  class EventsType < Types::BaseObject
    description 'The paginated events'

    field :items, [EventType, { null: true }], null: false
    field :pagination, EventPaginationType, null: false
  end
end
