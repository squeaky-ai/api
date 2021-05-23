# frozen_string_literal: true

module Types
  module Events
    class CursorType < Types::BaseObject
      description 'The cursor event object'

      field :type, String, null: false
      field :x, Integer, null: false
      field :y, Integer, null: false
      field :time, Integer, null: false
      field :timestamp, Integer, null: false
    end
  end
end
