# frozen_string_literal: true

module Types
  module Recordings
    class Event < Types::BaseObject
      graphql_name 'RecordingsEvent'

      field :id, ID, null: false
      field :data, Types::Events::Event, null: false
      field :type, Integer, null: false
      field :timestamp, GraphQL::Types::BigInt, null: false
    end
  end
end
