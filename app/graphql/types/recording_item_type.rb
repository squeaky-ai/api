# frozen_string_literal: true

module Types
  class RecordingItemType < Types::BaseObject
    description 'The recording object'

    field :id, ID, null: false # session_id
    field :active, Boolean, null: false
    field :user, String, null: false
    field :locale, String, null: false
    field :duration, Integer, null: false
    field :page_count, Integer, null: false
    field :start_page, String, null: false
    field :exit_page, String, null: false
    field :useragent, String, null: false
    field :viewport_x, Integer, null: false
    field :viewport_y, Integer, null: false
    field :created_at, String, null: false
    field :updated_at, String, null: true
  end
end
