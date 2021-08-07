# frozen_string_literal: true

module Types
  class VisitorPagesSortType < Types::BaseEnum
    description 'The sort options'

    value 'VIEWS_COUNT_DESC', 'Most amount of views first'
    value 'VIEWS_COUNT_ASC', 'Least amount of views first'
  end
end
