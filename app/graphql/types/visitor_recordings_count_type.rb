# frozen_string_literal: true

module Types
  class VisitorRecordingsCountType < Types::BaseObject
    description 'The visitors recordings item'

    field :total, Integer, null: false
    field :new, Integer, null: false
  end
end
