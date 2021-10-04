# frozen_string_literal: true

module Types
  class FiltersViewportType < BaseInputObject
    description 'The filters viewport object'

    argument :min_width, Integer, required: false
    argument :max_width, Integer, required: false
    argument :min_height, Integer, required: false
    argument :max_height, Integer, required: false
  end
end
