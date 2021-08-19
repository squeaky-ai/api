# frozen_string_literal: true

module Types
  class VisitorType < Types::BaseObject
    description 'The visitor object'

    field :visitor_id, String, null: false
    field :recording_count, Integer, null: false
    field :first_viewed_at, String, null: false
    field :last_activity_at, String, null: false
    field :language, String, null: false
    field :viewport_x, Integer, null: false
    field :viewport_y, Integer, null: false
    field :device_type, String, null: true
    field :browser, String, null: true
    field :browser_string, String, null: true
    field :page_view_count, Integer, null: true
    field :recordings, RecordingsType, null: false, extensions: [VisitorRecordingsExtension]
    field :pages, VisitorPagesType, null: false, extensions: [VisitorPagesExtension]
    field :average_session_duration, Integer, null: false, extensions: [VisitorAverageSessionDurationExtension]
    field :pages_per_session, Float, null: false, extensions: [VisitorPagesPerSessionExtension]
  end
end
