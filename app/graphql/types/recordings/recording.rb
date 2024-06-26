# frozen_string_literal: true

module Types
  module Recordings
    class Recording < Types::BaseObject
      graphql_name 'Recording'

      field :id, ID, null: false
      field :site_id, ID, null: false
      field :session_id, String, null: false
      field :viewed, Boolean, null: false
      field :bookmarked, Boolean, null: false
      field :language, String, null: false
      field :duration, GraphQL::Types::BigInt, null: false
      field :pages, [Types::Pages::Page, { null: false }], null: false
      field :page_views, [String, { null: false }], null: false
      field :page_count, Integer, null: false
      field :start_page, String, null: false
      field :exit_page, String, null: false
      field :referrer, String, null: true
      field :timezone, String, null: true
      field :country_code, String, null: true
      field :country_name, String, null: true
      field :device, Types::Recordings::Device, null: false
      field :connected_at, Types::Common::Dates, null: true
      field :disconnected_at, Types::Common::Dates, null: true
      field :tags, [Types::Tags::Tag, { null: false }], null: false
      field :notes, [Types::Notes::Note, { null: false }], null: false
      field :events, resolver: Resolvers::Recordings::Events
      field :visitor, resolver: Resolvers::Recordings::Visitor
      field :nps, Types::Feedback::NpsResponseItem, null: true
      field :sentiment, Types::Feedback::SentimentResponseItem, null: true
      field :activity_duration, GraphQL::Types::BigInt, null: true
      field :inactivity, [[GraphQL::Types::BigInt, { null: false }], { null: false }], null: false
      field :rage_clicked, Boolean, null: false
      field :u_turned, Boolean, null: false

      def connected_at
        DateFormatter.format(date: object.connected_at, timezone: context[:timezone])
      end

      def disconnected_at
        DateFormatter.format(date: object.disconnected_at, timezone: context[:timezone])
      end
    end
  end
end
