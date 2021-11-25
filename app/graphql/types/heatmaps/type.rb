# frozen_string_literal: true

module Types
  module Heatmaps
    class Type < Types::BaseEnum
      value 'Click', 'Show clicks'
      value 'Scroll', 'Show scrolls'
    end
  end
end
