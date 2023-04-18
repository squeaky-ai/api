# frozen_string_literal: true

module Types
  module Visitors
    class Sort < Types::BaseEnum
      graphql_name 'VisitorsSort'

      value 'first_viewed_at__desc', 'Most recently viewed'
      value 'first_viewed_at__asc', 'Least recently viewed'
      value 'last_activity_at__desc', 'Most recently active'
      value 'last_activity_at__asc', 'Least recently active'
      value 'recordings__desc', 'Most amount of recordings'
      value 'recordings__asc', 'Least amount of recordings'
    end
  end
end
