# typed: false
# frozen_string_literal: true

module Types
  module Visitors
    class PagesSort < Types::BaseEnum
      graphql_name 'VisitorsPagesSort'

      value 'views_count__desc', 'Most amount of views first'
      value 'views_count__asc', 'Least amount of views first'
      value 'average_time_on_page__desc', 'Longest average duration'
      value 'average_time_on_page__asc', 'Least amount of time on page'
    end
  end
end
