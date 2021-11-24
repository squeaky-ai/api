# frozen_string_literal: true

module Types
  module Nps
    class Groups < Types::BaseObject
      field :promoters, Integer, null: false
      field :passives, Integer, null: false
      field :detractors, Integer, null: false
    end
  end
end
