# frozen_string_literal: true

module Types
  class RecordingsFiltersDurationType < BaseInputObject
    description 'The recording filters duration object'

    argument :duration_range_type, RecordingsFiltersRangeType, required: false
    argument :duration_from_type, RecordingsFiltersSizeType, required: false
    argument :from_duration, String, required: false
    argument :between_from_duration, String, required: false
    argument :between_to_duration, String, required: false
  end
end
