# frozen_string_literal: true

module Types
  class NpsGroupsType < Types::BaseObject
    description 'The nps groups object'

    field :promoters, Integer, null: false
    field :passives, Integer, null: false
    field :detractors, Integer, null: false
  end
end
