# frozen_string_literal: true

module Types
  class RecordingsFiltersSizeType < Types::BaseEnum
    description 'The size options'

    value 'GreaterThan', 'Show recordings that have a duration longer than'
    value 'LessThan', 'Show recordings that have a duration shorter than'
  end
end
