# frozen_string_literal: true

module Types
  class HeatmapsTypeType < Types::BaseEnum
    description 'The heatmaps type options'

    value 'Click', 'Show clicks'
    value 'Scroll', 'Show scrolls'
  end
end
