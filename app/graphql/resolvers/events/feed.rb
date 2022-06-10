# frozen_string_literal: true

module Resolvers
  module Events
    class Feed < Resolvers::Base
      type Types::Events::Feed, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 20
      argument :sort, Types::Events::FeedSort, required: false, default_value: 'timestamp__desc'
      argument :group_ids, [ID], required: true
      argument :capture_ids, [ID], required: true

      def resolve(page:, size:, sort:, group_ids:, capture_ids:)
        puts '@@', page, size, sort, group_ids, capture_ids
        {
          items: [],
          pagination: {
            page_size: size,
            total: 0,
            sort:
          }
        }
      end

      private

      def order(sort)
        sorts = {
          'timestamp__asc' => 'timestamp ASC',
          'timestamp__desc' => 'timestamp DESC',
          'event_name__asc' => 'count ASC',
          'event_name__desc' => 'count DESC'
        }
        sorts[sort]
      end
    end
  end
end
