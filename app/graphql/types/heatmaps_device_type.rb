# frozen_string_literal: true

module Types
  class HeatmapsDeviceType < Types::BaseEnum
    description 'The heatmaps device options'

    value 'Desktop', 'Show desktop'
    value 'Tablet', 'Show tablet'
    value 'Mobile', 'Show mobile'
  end
end
