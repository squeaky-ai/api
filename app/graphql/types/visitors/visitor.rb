# frozen_string_literal: true

module Types
  module Visitors
    class Visitor < Types::BaseObject
      field :id, ID, null: false
      field :visitor_id, String, null: false
      field :viewed, Boolean, null: true
      field :recordings_count, Types::Visitors::RecordingsCount, null: true
      field :first_viewed_at, String, null: true
      field :last_activity_at, String, null: true
      field :language, String, null: true
      field :page_views_count, Types::Visitors::PagesCount, null: true
      field :starred, Boolean, null: false
      field :attributes, String, null: true
      field :devices, [Types::Recordings::Device], null: false
      field :recordings, resolver: Resolvers::Visitors::Recordings
      field :pages, resolver: Resolvers::Visitors::Pages
      field :average_session_duration, resolver: Resolvers::Visitors::AverageSessionDuration
      field :pages_per_session, resolver: Resolvers::Visitors::PagesPerSession
    end
  end
end
