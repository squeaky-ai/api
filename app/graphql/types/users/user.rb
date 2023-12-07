# frozen_string_literal: true

module Types
  module Users
    class User < Types::BaseObject
      graphql_name 'User'

      field :id, ID, null: false
      field :first_name, String, null: true
      field :last_name, String, null: true
      field :full_name, String, null: true
      field :email, String, null: false
      field :superuser, Boolean, null: false
      field :partner, Types::Users::Partner, null: true
      field :provider, String, null: true
      field :communication, Types::Users::Communication, null: true
      field :created_at, Types::Common::Dates, null: false
      field :updated_at, Types::Common::Dates, null: true
      field :last_activity_at, Types::Common::Dates, null: true
      field :current_provider, String, null: true

      def created_at
        DateFormatter.format(date: object.created_at, timezone: context[:timezone])
      end

      def updated_at
        DateFormatter.format(date: object.updated_at, timezone: context[:timezone])
      end

      def last_activity_at
        DateFormatter.format(date: object.last_activity_at, timezone: context[:timezone])
      end

      def current_provider
        context[:provider]
      end
    end
  end
end
