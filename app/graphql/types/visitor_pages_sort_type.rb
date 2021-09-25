# frozen_string_literal: true

module Types
  class VisitorPagesSortType < Types::BaseEnum
    description 'The sort options'

    value 'views_count__desc', 'Most amount of views first'
    value 'views_count__asc', 'Least amount of views first'
  end
end
