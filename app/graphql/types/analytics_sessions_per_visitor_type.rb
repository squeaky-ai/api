# frozen_string_literal: true

module Types
  class AnalyticsSessionsPerVisitorType < Types::BaseObject
    description 'The analytics session duration item'

    field :average, Float, null: false
    field :trend, Float, null: false
  end
end
