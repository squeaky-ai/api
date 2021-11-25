# frozen_string_literal: true

module Types
  module Nps
    class Scores < Types::BaseObject
      field :trend, Integer, null: false
      field :score, Integer, null: false
      field :responses, [Types::Nps::Score, { null: true }], null: false
    end
  end
end
