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
      field :pages, [Types::Pages::Page, { null: true }], null: false
      field :page_views, [String, { null: true }], null: false
      field :page_count, Integer, null: false
      field :start_page, String, null: false
      field :exit_page, String, null: false
      field :referrer, String, null: true
      field :device, Types::Recordings::Device, null: false
      field :connected_at, String, null: true
      field :disconnected_at, String, null: true
      field :tags, [Types::Tags::Tag, { null: true }], null: false
      field :notes, [Types::Notes::Note, { null: true }], null: false
      field :events, resolver: Resolvers::Recordings::Events
      field :previous_recording, Types::Recordings::Recording, null: true
      field :next_recording, Types::Recordings::Recording, null: true
      field :visitor, Types::Visitors::Visitor, null: false
      field :nps, Types::Feedback::NpsResponseItem, null: true
      field :sentiment, Types::Feedback::SentimentResponseItem, null: true
    end
  end
end
