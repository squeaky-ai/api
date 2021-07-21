# frozen_string_literal: true

module Types
  class RecordingType < Types::BaseObject
    description 'The recording object'

    field :id, ID, null: false
    field :site_id, ID, null: false
    field :session_id, String, null: false
    field :viewer_id, String, null: false
    field :active, Boolean, null: false
    field :language, String, null: false
    field :duration, Integer, null: false
    field :duration_string, String, null: false
    field :page_views, [String, { null: true }], null: false
    field :page_count, Integer, null: false
    field :start_page, String, null: false
    field :exit_page, String, null: false
    field :device_type, String, null: true
    field :browser, String, null: true
    field :browser_string, String, null: true
    field :viewport_x, Integer, null: true
    field :viewport_y, Integer, null: true
    field :date_string, String, null: true
    field :tags, [TagType, { null: true }], null: false
    field :notes, [NoteType, { null: true }], null: false
    field :events, String, null: false, extensions: [EventExtension]
  end
end
