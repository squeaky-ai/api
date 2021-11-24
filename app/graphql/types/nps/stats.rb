# frozen_string_literal: true

module Types
  module Nps
    class Stats < Types::BaseObject
      field :displays, Integer, null: false
      field :ratings, Integer, null: false
    end
  end
end
