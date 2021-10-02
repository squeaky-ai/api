# frozen_string_literal: true

module Types
  class RecordingsFiltersDurationType < BaseInputObject
    description 'The recording filters duration object'

    argument :duration_range_type, RecordingsFiltersRangeType, required: false
    argument :duration_from_type, RecordingsFiltersSizeType, required: false
    argument :from_duration, Integer, required: false
    argument :between_from_duration, Integer, required: false
    argument :between_to_duration, Integer, required: false
  end
end
