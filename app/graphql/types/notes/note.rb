# typed: false
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
      field :created_at, Types::Common::Dates, null: false
      field :updated_at, Types::Common::Dates, null: true

      def created_at
        DateFormatter.format(date: object.created_at, timezone: context[:timezone])
      end

      def updated_at
        DateFormatter.format(date: object.updated_at, timezone: context[:timezone])
      end
    end
  end
end
