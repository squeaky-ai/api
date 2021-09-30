# frozen_string_literal: true

module Types
  class RecordingsFiltersViewportType < BaseInputObject
    description 'The recording filters viewport object'

    argument :min_width, String, required: false
    argument :max_width, String, required: false
    argument :min_height, String, required: false
    argument :max_height, String, required: false
  end
end
