# frozen_string_literal: true

module Types
  module Visitors
    class Filters < BaseInputObject
      argument :status, Types::Common::FiltersStatus, required: false
      argument :recordings, Types::Common::FiltersRecordings, required: true
      argument :first_visited, Types::Common::FiltersDate, required: true
      argument :last_activity, Types::Common::FiltersDate, required: true
      argument :languages, [String], required: true
    end
  end
end
