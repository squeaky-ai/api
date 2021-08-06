# frozen_string_literal: true

module Types
  class VisitorSortType < Types::BaseEnum
    description 'The sort options'

    value 'RECORDINGS_COUNT_DESC', 'Most amount of recordings first'
    value 'RECORDING_COUNT_ASC', 'Least amount of recordings first'
    value 'FIRST_VIEWED_AT_DESC', 'Most recently viewed'
    value 'FIRST_VIEWED_AT_ASC', 'Least recently viewed'
    value 'LAST_ACTIVITY_AT_DESC', 'Most recently active'
    value 'LAST_ACTIVITY_AT_ASC', 'Least recently active'
  end
end
