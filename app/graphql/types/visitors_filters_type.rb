# frozen_string_literal: true

module Types
  class VisitorsFiltersType < BaseInputObject
    description 'The visitor filters input'

    argument :status, FiltersStatusType, required: false
    argument :recordings, FiltersRecordingsType, required: true
    argument :first_visited, FiltersDateType, required: true
    argument :last_activity, FiltersDateType, required: true
    argument :languages, [String], required: true
  end
end
