# typed: false
# frozen_string_literal: true

module Types
  module Analytics
    class Dimension < Types::BaseObject
      graphql_name 'AnalyticsDimension'

      field :device_x, Integer, null: false
      field :count, Integer, null: false
    end
  end
end
