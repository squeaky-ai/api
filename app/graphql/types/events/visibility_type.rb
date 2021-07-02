# frozen_string_literal: true

module Types
  module Events
    class VisibilityType < Types::BaseObject
      description 'The visibility event object'

      field :event_id, String, null: false
      field :type, String, null: false
      field :visible, Boolean, null: false
      field :timestamp, GraphQL::Types::BigInt, null: false
    end
  end
end
