# frozen_string_literal: true

module Types
  class RecordingPaginationType < Types::BaseObject
    description 'Pagination for recording objects'

    field :page_size, Integer, null: false
    field :page_count, Integer, null: false
    field :sort, SortType, null: false
  end
end
