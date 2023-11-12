# frozen_string_literal: true

module Types
  module Admin
    class Site < Types::Sites::Site
      graphql_name 'AdminSite'

      field :ingest_enabled, Boolean, null: false
      field :recording_counts, resolver: Resolvers::Admin::SiteRecordingsCounts
      field :bundled, Boolean, null: false, method: :bundled?
      field :bundled_with, [Types::Admin::Site, { null: false }], null: false
    end
  end
end
