# frozen_string_literal: true

module Types
  module Events
    class CursorType < Types::BaseObject
      description 'The cursor event object'

      field :event_id, String, null: false
      field :type, String, null: false
      field :x, Integer, null: false
      field :y, Integer, null: false
      field :offset_x, Integer, null: false
      field :offset_y, Integer, null: false
      field :timestamp, GraphQL::Types::BigInt, null: false
    end
  end
end
