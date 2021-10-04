# frozen_string_literal: true

module Types
  class FiltersDateType < BaseInputObject
    description 'The filters date object'

    argument :range_type, FiltersRangeType, required: false
    argument :from_type, FiltersStartType, required: false
    argument :from_date, String, required: false
    argument :between_from_date, String, required: false
    argument :between_to_date, String, required: false
  end
end
