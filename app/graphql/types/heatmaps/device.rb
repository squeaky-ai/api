# typed: false
# frozen_string_literal: true

module Types
  module Heatmaps
    class Device < Types::BaseEnum
      graphql_name 'HeatmapsDevice'

      value 'Desktop', 'Show desktop'
      value 'Tablet', 'Show tablet'
      value 'Mobile', 'Show mobile'
    end
  end
end
