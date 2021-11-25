# frozen_string_literal: true

module Types
  module Common
    class FiltersRecordings < BaseInputObject
      argument :range_type, Types::Common::FiltersRange, required: false
      argument :count, Integer, required: false
    end
  end
end
