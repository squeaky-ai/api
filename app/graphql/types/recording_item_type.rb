# frozen_string_literal: true

module Types
  class RecordingItemType < Types::BaseObject
    description 'The recording object'

    field :id, ID, null: false
    field :site_id, ID, null: false
    field :viewer_id, String, null: false
    field :active, Boolean, null: false
    field :locale, String, null: false
    field :duration, Integer, null: false
    field :page_count, Integer, null: false
    field :start_page, String, null: false
    field :exit_page, String, null: false
    field :useragent, String, null: false
    field :viewport_x, Integer, null: false
    field :viewport_y, Integer, null: false
    field :events, EventType, null: false, extensions: [EventExtension]
    field :connected_at, String, null: false
    field :disconnected_at, String, null: true
  end
end
