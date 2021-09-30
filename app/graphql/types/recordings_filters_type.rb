# frozen_string_literal: true

module Types
  class RecordingsFiltersType < BaseInputObject
    description 'The recording filters input'

    argument :browsers, [String], required: true
    argument :devices, [String], required: true
    argument :languages, [String], required: true
    argument :start_url, String, required: false
    argument :exit_url, String, required: false
    argument :visited_pages, [String], required: true
    argument :unvisited_pages, [String], required: true
    argument :status, RecordingsFiltersStatusType, required: false
    argument :date, RecordingsFiltersDateType, required: true
    argument :duration, RecordingsFiltersDurationType, required: true
    argument :viewport, RecordingsFiltersViewportType, required: true
  end
end
