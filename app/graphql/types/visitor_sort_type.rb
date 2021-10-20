# frozen_string_literal: true

module Types
  class VisitorSortType < Types::BaseEnum
    description 'The sort options'

    value 'first_viewed_at__desc', 'Most recently viewed'
    value 'first_viewed_at__asc', 'Least recently viewed'
    value 'last_activity_at__desc', 'Most recently active'
    value 'last_activity_at__asc', 'Least recently active'
  end
end
