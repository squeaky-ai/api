# frozen_string_literal: true

module Types
  module Events
    class InteractionType < Types::BaseObject
      description 'The interaction event object'

      field :event_id, String, null: false
      field :type, String, null: false
      field :selector, String, null: false
      field :node, String, null: false
      field :time, Integer, null: false
      field :timestamp, GraphQL::Types::BigInt, null: false
    end
  end
end
