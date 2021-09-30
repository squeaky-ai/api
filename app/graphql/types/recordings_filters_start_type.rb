# frozen_string_literal: true

module Types
  class RecordingsFiltersStartType < Types::BaseEnum
    description 'The start options'

    value 'Before', 'Show recordings that start before this time'
    value 'After', 'Show recordings that start after this time'
  end
end
