# frozen_string_literal: true

module Types
  class FiltersRecordingsType < BaseInputObject
    description 'The filters recording object'

    argument :range_type, FiltersRangeType, required: false
    argument :count, Integer, required: false
  end
end
