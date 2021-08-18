# frozen_string_literal: true

module Types
  class NotePaginationType < Types::BaseObject
    description 'Pagination for notes objects'

    field :page_size, Integer, null: false
    field :total, Integer, null: false
  end
end
