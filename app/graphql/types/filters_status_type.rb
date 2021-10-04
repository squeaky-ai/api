# frozen_string_literal: true

module Types
  class FiltersStatusType < Types::BaseEnum
    description 'The status options'

    value 'New', 'Show only new recordings'
    value 'Viewed', 'Show only viewed recordings'
  end
end
