# frozen_string_literal: true

module Types
  class RecordingsFiltersViewportType < BaseInputObject
    description 'The recording filters viewport object'

    argument :min_width, Integer, required: false
    argument :max_width, Integer, required: false
    argument :min_height, Integer, required: false
    argument :max_height, Integer, required: false
  end
end
