# frozen_string_literal: true

module Types
  class SortType < Types::BaseEnum
    description 'The sort options'

    value 'DESC', 'Most recent first'
    value 'ASC', 'Oldest first'
  end
end
