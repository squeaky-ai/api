# frozen_string_literal: true

module Types
  class NpsResponseSortType < Types::BaseEnum
    description 'The sort options'

    value 'timestamp__desc', 'Most recent response first'
    value 'timestamp__asc', 'Oldest response first'
  end
end
