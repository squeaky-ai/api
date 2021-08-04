# frozen_string_literal: true

module Types
  class AnalyticsDimensionsType < Types::BaseObject
    description 'The analytics dimensions item'

    field :min, Integer, null: false
    field :max, Integer, null: false
    field :avg, Integer, null: false
  end
end
