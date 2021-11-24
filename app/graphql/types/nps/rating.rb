# frozen_string_literal: true

module Types
  module Nps
    class Rating < Types::BaseObject
      field :score, Integer, null: false
    end
  end
end
