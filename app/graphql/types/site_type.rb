# frozen_string_literal: true

module Types
  class SiteType < Types::BaseObject
    description 'The site object'

    field :id, ID, null: false
    field :name, String, null: false
    field :url, String, null: false
    field :avatar, String, null: true
    field :plan, Integer, null: false
    field :plan_name, String, null: false
    field :uuid, String, null: false
    field :owner_name, String, null: false
    field :verified_at, String, null: true
    field :checklist_dismissed_at, String, null: true
    field :days_since_last_recording, Integer, null: false, extensions: [LastRecordingExtension]
    field :team, [TeamType], null: false
    # Fetch a single recording
    field :recording, RecordingType, null: true, extensions: [RecordingExtension]
    # Fetch a list of recordings, refrain from fetching
    # events inside of here to prevent n+1
    field :recordings, RecordingsType, null: false, extensions: [RecordingsExtension]
    field :analytics, AnalyticsType, null: false, extensions: [AnalyticsExtension]
    field :created_at, String, null: false
    field :updated_at, String, null: true
  end
end
