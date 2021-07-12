# frozen_string_literal: true

module Types
  class TagType < Types::BaseObject
    description 'The tag object'

    field :id, ID, null: false
    field :name, String, null: false
    field :created_at, String, null: false
    field :updated_at, String, null: true
  end
end
