# frozen_string_literal: true

module Types
  class RecordingsType < Types::BaseObject
    description 'The paginated recordings'

    field :items, [RecordingType, { null: true }], null: false
    field :pagination, RecordingPaginationType, null: false
  end
end
