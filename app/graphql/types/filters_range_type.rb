# frozen_string_literal: true

module Types
  class FiltersRangeType < Types::BaseEnum
    description 'The range options'

    value 'From', 'Show recordings are longer than this time'
    value 'Between', 'Show recordings that fit within this time'
  end
end
