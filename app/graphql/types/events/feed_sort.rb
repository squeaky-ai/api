# typed: false
# frozen_string_literal: true

module Types
  module Events
    class FeedSort < Types::BaseEnum
      graphql_name 'EventsFeedSort'

      value 'timestamp__asc', 'Oldest first'
      value 'timestamp__desc', 'Newest first'
    end
  end
end
