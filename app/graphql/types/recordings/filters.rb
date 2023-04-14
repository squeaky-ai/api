# typed: false
# frozen_string_literal: true

module Types
  module Recordings
    class Filters < BaseInputObject
      graphql_name 'RecordingsFilters'

      argument :browsers, [String], required: true
      argument :devices, [String], required: true
      argument :languages, [String], required: true
      argument :start_url, String, required: false
      argument :exit_url, String, required: false
      argument :visited_pages, [String], required: true
      argument :unvisited_pages, [String], required: true
      argument :bookmarked, Boolean, required: false
      argument :referrers, [String], required: true
      argument :starred, Boolean, required: false
      argument :tags, [Integer], required: true
      argument :status, Types::Common::FiltersStatus, required: false
      argument :duration, Types::Common::FiltersDuration, required: true
      argument :viewport, Types::Common::FiltersViewport, required: true
      argument :utm_source, String, required: false
      argument :utm_campaign, String, required: false
      argument :utm_medium, String, required: false
      argument :utm_term, String, required: false
      argument :utm_content, String, required: false
      argument :visitor_type, Types::Common::FiltersVisitorType, required: false
    end
  end
end
