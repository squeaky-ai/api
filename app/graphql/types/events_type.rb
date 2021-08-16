# frozen_string_literal: true

module Types
  class EventsType < Types::BaseObject
    description 'The paginated events'

    field :items, [String, { null: true }], null: false
    field :pagination, EventPaginationType, null: false
  end
end
