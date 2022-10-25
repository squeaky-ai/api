# frozen_string_literal: true

module Types
  module Events
    class Feed < Types::BaseObject
      graphql_name 'EventsFeed'

      field :items, [Events::FeedItem, { null: false }], null: false
      field :pagination, Types::Events::FeedPagination, null: false
    end
  end
end
