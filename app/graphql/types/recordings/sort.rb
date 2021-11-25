# frozen_string_literal: true

module Types
  module Recordings
    class Sort < Types::BaseEnum
      graphql_name 'RecordingsSort'

      value 'connected_at__desc', 'Most recent recordings first'
      value 'connected_at__asc', 'Oldest recordings first'
      value 'duration__desc', 'Longest recordings first'
      value 'duration__asc', 'Shortest recordings first'
      value 'page_count__desc', 'Most page views first'
      value 'page_count__asc', 'Least page views first'
    end
  end
end
