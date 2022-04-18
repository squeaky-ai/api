# frozen_string_literal: true

module Types
  module Visitors
    class Filters < BaseInputObject
      graphql_name 'VisitorsFilters'

      argument :status, Types::Common::FiltersStatus, required: false
      argument :recordings, Types::Common::FiltersRecordings, required: true
      argument :first_visited, Types::Common::FiltersDate, required: true
      argument :last_activity, Types::Common::FiltersDate, required: true
      argument :languages, [String], required: true
      argument :visited_pages, [String], required: true
      argument :unvisited_pages, [String], required: true
      argument :referrers, [String], required: true
      argument :starred, Boolean, required: false
    end
  end
end
