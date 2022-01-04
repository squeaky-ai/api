# frozen_string_literal: true

module Types
  module Notes
    class Note < Types::BaseObject
      graphql_name 'Note'

      field :id, ID, null: false
      field :body, String, null: false
      field :timestamp, Int, null: true
      field :user, Types::Users::User, null: true
      field :recording_id, Integer, null: false
      field :session_id, String, null: true
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
    end
  end
end
