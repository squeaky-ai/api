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
      field :recordings, RecordingsType, null: true, extensions: [VisitorRecordingsExtension]
      field :pages, VisitorPagesType, null: true, extensions: [VisitorPagesExtension]
      field :average_session_duration, Integer, null: true, extensions: [VisitorAverageSessionDurationExtension]
      field :pages_per_session, Float, null: true, extensions: [VisitorPagesPerSessionExtension]
    end
  end
end
