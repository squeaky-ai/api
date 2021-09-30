# frozen_string_literal: true

module Types
  class RecordingsFiltersDateType < BaseInputObject
    description 'The recording filters date object'

    argument :date_range_type, RecordingsFiltersRangeType, required: false
    argument :date_from_type, RecordingsFiltersStartType, required: false
    argument :from_date, String, required: false
    argument :between_from_date, String, required: false
    argument :between_to_date, String, required: false
  end
end
