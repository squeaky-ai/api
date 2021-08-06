# frozen_string_literal: true

module Types
  class RecordingPaginationType < Types::BaseObject
    description 'Pagination for recording objects'

    field :page_size, Integer, null: false
    field :total, Integer, null: false
    field :sort, RecordingSortType, null: false
  end
end
