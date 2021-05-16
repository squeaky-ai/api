# frozen_string_literal: true

module Types
  class PaginationType < Types::BaseObject
    description 'The pagination object'

    field :cursor, String, null: true
    field :is_last, Boolean, null: false
    field :total, Integer, null: false
  end
end
