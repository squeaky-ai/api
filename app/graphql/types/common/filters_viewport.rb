# frozen_string_literal: true

module Types
  module Common
    class FiltersViewport < BaseInputObject
      argument :min_width, Integer, required: false
      argument :max_width, Integer, required: false
      argument :min_height, Integer, required: false
      argument :max_height, Integer, required: false
    end
  end
end
