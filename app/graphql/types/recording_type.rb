# frozen_string_literal: true

module Types
  class RecordingType < Types::BaseObject
    description 'The recording object'

    field :id, ID, null: false
    field :site_id, ID, null: false
    field :session_id, String, null: false
    field :viewed, Boolean, null: false
    field :bookmarked, Boolean, null: false
    field :language, String, null: false
    field :duration, GraphQL::Types::BigInt, null: false
    field :page_views, [String, { null: true }], null: false
    field :page_count, Integer, null: false
    field :start_page, String, null: false
    field :exit_page, String, null: false
    field :device, DeviceType, null: false
    field :connected_at, String, null: true
    field :disconnected_at, String, null: true
    field :tags, [TagType, { null: true }], null: false
    field :notes, [NoteType, { null: true }], null: false
    field :events, EventsType, null: false, extensions: [EventExtension]
    field :previous_recording, RecordingType, null: true
    field :next_recording, RecordingType, null: true
    field :visitor, VisitorType, null: false
  end
end
