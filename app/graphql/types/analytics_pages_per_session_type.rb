# frozen_string_literal: true

module Types
  class AnalyticsPagesPerSessionType < Types::BaseObject
    description 'The analytics session pages item'

    field :average, Float, null: false
    field :trend, Float, null: false
  end
end
