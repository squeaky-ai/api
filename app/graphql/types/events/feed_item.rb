# frozen_string_literal: true

module Types
  module Events
    class FeedItem < Types::BaseObject
      graphql_name 'FeedCaptureItem'

      field :id, ID, null: false
      field :event_name, String, null: false
      field :source, String, null: true
      field :data, String, null: true
      field :timestamp, GraphQL::Types::ISO8601DateTime, null: false
      field :visitor, Types::Visitors::Visitor, null: false
      field :recording, Types::Recordings::Recording, null: true
    end
  end
end
