# frozen_string_literal: true

module Types
  class NpsScoreType < Types::BaseObject
    description 'The nps score object'

    field :score, Integer, null: false
    field :timestamp, String, null: false
  end
end
