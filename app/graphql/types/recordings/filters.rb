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
      argument :status, Types::Common::FiltersStatus, required: false
      argument :date, Types::Common::FiltersDate, required: true
      argument :duration, Types::Common::FiltersDuration, required: true
      argument :viewport, Types::Common::FiltersViewport, required: true
    end
  end
end
