# frozen_string_literal: true

# TODO: we need a union type here

module Types
  class EventType < Types::BaseObject
    description 'The event object'

    field :type, String, null: false
    field :selector, String, null: true
    field :x, Integer, null: true
    field :y, Integer, null: true
    field :time, Integer, null: false
    field :timestamp, Integer, null: false
  end
end
