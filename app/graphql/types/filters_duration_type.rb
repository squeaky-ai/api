# frozen_string_literal: true

module Types
  class FiltersDurationType < BaseInputObject
    description 'The recording filters duration object'

    argument :range_type, FiltersRangeType, required: false
    argument :from_type, FiltersSizeType, required: false
    argument :from_duration, Integer, required: false
    argument :between_from_duration, Integer, required: false
    argument :between_to_duration, Integer, required: false
  end
end
