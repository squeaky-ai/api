# frozen_string_literal: true

module Types
  module Visitors
    class PagesSort < Types::BaseEnum
      graphql_name 'VisitorsPagesSort'

      value 'views_count__desc', 'Most amount of views first'
      value 'views_count__asc', 'Least amount of views first'
    end
  end
end
