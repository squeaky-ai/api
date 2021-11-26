# frozen_string_literal: true

module Types
  module Notes
    class Note < Types::BaseObject
      graphql_name 'Note'

      field :id, ID, null: false
      field :body, String, null: false
      field :timestamp, Integer, null: true
      field :user, Types::Users::User, null: true
      field :recording_id, Integer, null: false
      field :session_id, String, null: true
      field :created_at, String, null: false
      field :updated_at, String, null: true
    end
  end
end
