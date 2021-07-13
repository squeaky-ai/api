# frozen_string_literal: true

module Types
  class NoteType < Types::BaseObject
    description 'The note object'

    field :id, ID, null: false
    field :body, String, null: false
    field :timestamp, Integer, null: true
    field :user, UserType, null: false
    field :created_at, String, null: false
    field :updated_at, String, null: true
  end
end
