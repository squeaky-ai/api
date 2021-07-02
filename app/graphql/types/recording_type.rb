# frozen_string_literal: true

module Types
  class RecordingType < Types::BaseObject
    description 'The recording object'

    field :id, ID, null: false
    field :site_id, ID, null: false
    field :viewer_id, String, null: false
    field :active, Boolean, null: false
    field :language, String, null: false
    field :duration, Integer, null: false
    field :duration_string, String, null: false
    field :pages, [String, { null: true }], null: false
    field :page_count, Integer, null: false
    field :start_page, String, null: false
    field :exit_page, String, null: false
    field :device_type, String, null: true
    field :browser, String, null: true
    field :browser_string, String, null: true
    field :viewport_x, Integer, null: false
    field :viewport_y, Integer, null: false
    field :date_string, String, null: false
    field :timestamp, GraphQL::Types::BigInt, null: false
    field :events, [EventType, { null: true }], null: false, extensions: [EventsExtension]
  end
end
