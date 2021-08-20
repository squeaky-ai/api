# frozen_string_literal: true

module Types
  class VisitorType < Types::BaseObject
    description 'The visitor object'

    field :id, ID, null: false
    field :visitor_id, String, null: false
    field :recording_count, Integer, null: true
    field :first_viewed_at, String, null: true
    field :last_activity_at, String, null: true
    field :language, String, null: true
    field :viewport_x, Integer, null: true
    field :viewport_y, Integer, null: true
    field :device_type, String, null: true
    field :browser, String, null: true
    field :browser_string, String, null: true
    field :page_view_count, Integer, null: true
    field :starred, Boolean, null: false
    field :recordings, RecordingsType, null: true, extensions: [VisitorRecordingsExtension]
    field :pages, VisitorPagesType, null: true, extensions: [VisitorPagesExtension]
    field :average_session_duration, Integer, null: true, extensions: [VisitorAverageSessionDurationExtension]
    field :pages_per_session, Float, null: true, extensions: [VisitorPagesPerSessionExtension]
  end
end
