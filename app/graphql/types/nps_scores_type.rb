# frozen_string_literal: true

module Types
  class NpsScoresType < Types::BaseObject
    description 'The nps scores object'

    field :trend, Integer, null: false
    field :score, Integer, null: false
    field :responses, [NpsScoreType, { null: true }], null: false
  end
end
