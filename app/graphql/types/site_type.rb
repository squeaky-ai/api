# frozen_string_literal: true

module Types
  class SiteType < Types::BaseObject
    description 'The site object'

    field :id, ID, null: false
    field :name, String, null: false
    field :url, String, null: false
    field :plan, Integer, null: false
    field :plan_name, String, null: false
    field :uuid, String, null: false
    field :owner_name, String, null: false
    field :verified_at, String, null: true
    field :days_since_last_recording, Integer, null: false, extensions: [LastRecordingExtension]
    field :team, [TeamType], null: false
    field :team_size_exceeded, Boolean, null: false
    field :notes, NotesType, null: true, extensions: [NotesExtension]
    field :pages, [String, { null: true }], null: false, extensions: [PagesExtension]
    field :languages, [String, { null: true }], null: false, extensions: [LanguagesExtension]
    field :browsers, [String, { null: true }], null: false, extensions: [BrowsersExtension]
    field :ip_blacklist, [IpBlacklistType, { null: true }], null: false
    field :domain_blacklist, [DomainBlacklistType, { null: true }], null: false
    field :recordings_count, Integer, null: false
    field :feedback, FeedbackType, null: true
    field :tags, [TagType, { null: true }], null: false
    # Fetch the data for heatmaps
    field :heatmaps, HeatmapsType, null: false, extensions: [HeatmapsExtension]
    # Fetch a single recording
    field :recording, RecordingType, null: true, extensions: [RecordingExtension]
    # Fetch a list of recordings, refrain from fetching
    # events inside of here to prevent n+1
    field :recordings, RecordingsType, null: false, extensions: [RecordingsExtension]
    # Fetch the latest recording
    field :recording_latest, RecordingType, null: true, extensions: [RecordingLatestExtension]
    # Fetch a single visitor
    field :visitor, VisitorType, null: true, extensions: [VisitorExtension]
    # Fetch a list of visitors, refrain from fetching
    # anything deeper to prevent n+
    field :visitors, VisitorsType, null: false, extensions: [VisitorsExtension]
    # Add some top level arguments for the analytics so that
    # each individual extension does not need to implement it
    field :analytics, AnalyticsType, null: false do
      argument :from_date, String, required: true, description: 'The to start from'
      argument :to_date, String, required: true, description: 'The to end at'
    end
    field :created_at, String, null: false
    field :updated_at, String, null: true
  end
end
