# frozen_string_literal: true

module Types
  class VisitorsFiltersType < BaseInputObject
    description 'The visitor filters input'

    argument :status, FiltersStatusType, required: false
    argument :recordings, FiltersRecordingsType, required: true
    argument :first_visited, FiltersDateType, required: true
    argument :last_activity, FiltersDateType, required: true
    argument :start_url, String, required: false
    argument :exit_url, String, required: false
    argument :visited_pages, [String], required: true
    argument :unvisited_pages, [String], required: true
    argument :languages, [String], required: true
  end
end
