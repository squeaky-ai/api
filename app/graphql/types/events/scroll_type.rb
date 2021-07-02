# frozen_string_literal: true

module Types
  module Events
    class ScrollType < Types::BaseObject
      description 'The scroll event object'

      field :event_id, String, null: false
      field :type, String, null: false
      field :x, Integer, null: false
      field :y, Integer, null: false
      field :time, Integer, null: false
      field :timestamp, GraphQL::Types::BigInt, null: false
    end
  end
end
