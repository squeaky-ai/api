# frozen_string_literal: true

module Types
  module Admin
    class Site < Types::Sites::Site
      graphql_name 'AdminSite'

      field :recording_counts, resolver: Resolvers::Admin::SiteRecordingsCounts
    end
  end
end
