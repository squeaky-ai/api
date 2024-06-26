# frozen_string_literal: true

module Types
  module Visitors
    class Visitor < Types::BaseObject
      graphql_name 'Visitor'

      field :id, ID, null: false
      field :visitor_id, String, null: false
      field :viewed, Boolean, null: true
      field :recording_count, Types::Visitors::RecordingCount, null: true
      field :first_viewed_at, Types::Common::Dates, null: true
      field :last_activity_at, Types::Common::Dates, null: true
      field :language, String, null: true
      field :page_views_count, Types::Visitors::PagesCount, null: true
      field :starred, Boolean, null: true
      field :linked_data, String, null: true
      field :devices, [Types::Recordings::Device], null: false
      field :countries, [Types::Recordings::Country], null: false
      field :recordings, resolver: Resolvers::Visitors::Recordings
      field :pages, resolver: Resolvers::Visitors::Pages
      field :average_session_duration, resolver: Resolvers::Visitors::AverageSessionDuration
      field :pages_per_session, resolver: Resolvers::Visitors::PagesPerSession
      field :export, resolver: Resolvers::Visitors::Export
      field :events, resolver: Resolvers::Visitors::Events
      field :source, Types::Common::Source, null: true
      field :average_recording_duration, GraphQL::Types::BigInt, null: true
      field :created_at, Types::Common::Dates, null: false

      def created_at
        DateFormatter.format(date: object.created_at, timezone: context[:timezone])
      end

      def first_viewed_at
        DateFormatter.format(date: object.first_viewed_at, timezone: context[:timezone])
      end

      def last_activity_at
        DateFormatter.format(date: object.last_activity_at, timezone: context[:timezone])
      end
    end
  end
end
