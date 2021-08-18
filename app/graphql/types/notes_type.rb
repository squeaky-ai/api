# frozen_string_literal: true

module Types
  class NotesType < Types::BaseObject
    description 'The paginated notes'

    field :items, [NoteType, { null: true }], null: false
    field :pagination, NotePaginationType, null: false
  end
end
