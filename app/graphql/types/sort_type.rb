# frozen_string_literal: true

module Types
  class SortType < Types::BaseEnum
    description 'The sort options'

    value 'DATE_DESC', 'Most recent recordings first'
    value 'DATE_ASC', 'Oldest recordings first'
    value 'DURATION_DESC', 'Longest recordings first'
    value 'DURATION_ASC', 'Shortest recordings first'
    value 'PAGE_SIZE_DESC', 'Most page views first'
    value 'PAGE_SIZE_ASC', 'Least page views first'
  end
end
