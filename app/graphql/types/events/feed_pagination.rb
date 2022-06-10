# frozen_string_literal: true

module Types
  module Events
    class FeedPagination < Types::BaseObject
      graphql_name 'EventsFeedPagination'

      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, Types::Events::FeedSort, null: false
    end
  end
end
