# frozen_string_literal: true

module Types
  module Events
    class SnapshotType < Types::BaseObject
      description 'The snapshot event object'

      field :event_id, String, null: false
      field :type, String, null: false
      field :event, String, null: false
      field :snapshot, String, null: false
      field :timestamp, GraphQL::Types::BigInt, null: false
    end
  end
end
