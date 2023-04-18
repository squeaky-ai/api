# typed: false
# frozen_string_literal: true

module Types
  module Teams
    class Team < Types::BaseObject
      graphql_name 'Team'

      field :id, ID, null: false
      field :status, Integer, null: false
      field :role, Integer, null: false
      field :role_name, String, null: false
      field :user, Types::Users::User, null: false
      field :linked_data_visible, Boolean, null: false
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
