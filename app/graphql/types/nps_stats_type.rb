# frozen_string_literal: true

module Types
  class NpsStatsType < Types::BaseObject
    description 'The nps stats object'

    field :displays, Integer, null: false
    field :ratings, Integer, null: false
  end
end
