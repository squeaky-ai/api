# frozen_string_literal: true

module Types
  module Sites
    class Site < Types::BaseObject
      field :id, ID, null: false
      field :name, String, null: false
      field :url, String, null: false
      field :plan, Integer, null: false
      field :plan_name, String, null: false
      field :uuid, String, null: false
      field :owner_name, String, null: false
      field :verified_at, String, null: true
      field :team, [Types::Sites::Team], null: false
      field :team_size_exceeded, Boolean, null: false
      field :days_since_last_recording, resolver: Resolvers::Recordings::DaysSinceLastRecording
      field :notes, Types::Notes::Notes, resolver: Resolvers::Notes::Notes
      field :pages, resolver: Resolvers::Pages::Pages
      field :languages, resolver: Resolvers::Sites::Languages
      field :browsers, resolver: Resolvers::Sites::Browsers
      field :ip_blacklist, [Types::Sites::IpBlacklist, { null: true }], null: false
      field :domain_blacklist, [Types::Sites::DomainBlacklist, { null: true }], null: false
      field :recordings_count, Integer, null: false
      field :feedback, Types::Feedback::Feedback, null: true
      field :tags, [Types::Tags::Tag, { null: true }], null: false
      field :heatmaps, resolver: Resolvers::Heatmaps::Heatmaps
      field :recording, resolver: Resolvers::Recordings::Recording
      field :recordings, resolver: Resolvers::Recordings::Recordings
      field :recording_latest, resolver: Resolvers::Recordings::Latest
      field :visitor, resolver: Resolvers::Visitors::Visitor
      field :visitors, resolver: Resolvers::Visitors::Visitors
      field :analytics, Types::Analytics::Analytics, null: false do
        argument :from_date, String, required: true
        argument :to_date, String, required: true
      end
      field :nps, Types::Nps::Nps, null: false do
        argument :from_date, String, required: true
        argument :to_date, String, required: true
      end
      field :sentiment, Types::Sentiment::Sentiment, null: false do
        argument :from_date, String, required: true
        argument :to_date, String, required: true
      end
      field :created_at, String, null: false
      field :updated_at, String, null: true
    end
  end
end
