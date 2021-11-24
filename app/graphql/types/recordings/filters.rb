# frozen_string_literal: true

module Types
  module Recordings
    class Filters < BaseInputObject
      argument :browsers, [String], required: true
      argument :devices, [String], required: true
      argument :languages, [String], required: true
      argument :start_url, String, required: false
      argument :exit_url, String, required: false
      argument :visited_pages, [String], required: true
      argument :unvisited_pages, [String], required: true
      argument :status, FiltersStatusType, required: false
      argument :date, FiltersDateType, required: true
      argument :duration, FiltersDurationType, required: true
      argument :viewport, FiltersViewportType, required: true
    end
  end
end
