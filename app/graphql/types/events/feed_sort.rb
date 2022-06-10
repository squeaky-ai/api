# frozen_string_literal: true

module Types
  module Events
    class FeedSort < Types::BaseEnum
      graphql_name 'EventsFeedSort'

      value 'timestamp__asc', 'Oldest first'
      value 'timestamp__desc', 'Newest first'
      value 'event_name__asc', 'Name of event ascending (A-Z)'
      value 'event_name__desc', 'Name of event descending (Z-A)'
    end
  end
end
