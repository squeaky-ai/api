# frozen_string_literal: true

module Types
  module Common
    class FiltersDuration < BaseInputObject
      argument :range_type, Types::Common::FiltersRange, required: false
      argument :from_type, Types::Common::FiltersSize, required: false
      argument :from_duration, Integer, required: false
      argument :between_from_duration, Integer, required: false
      argument :between_to_duration, Integer, required: false
    end
  end
end
