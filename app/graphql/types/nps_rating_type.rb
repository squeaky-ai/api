# frozen_string_literal: true

module Types
  class NpsRatingType < Types::BaseObject
    description 'The nps rating object'

    field :score, Integer, null: false
  end
end
