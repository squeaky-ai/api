# frozen_string_literal: true

module Types
  class RecordingType < Types::BaseObject
    description 'The paginated recordings'

    field :items, [RecordingItemType, { null: true }], null: false
    field :pagination, PaginationType, null: false
  end
end
