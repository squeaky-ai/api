# frozen_string_literal: true

module Resolvers
  module Events
    class Capture < Resolvers::Base
      type Types::Events::Capture, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 20
      argument :sort, Types::Events::CaptureSort, required: false, default_value: 'count_desc'

      def resolve(page:, size:, sort:)
        events = Site
                 .find(object.id)
                 .event_captures
                 .order(order(sort))
                 .page(page)
                 .per(size)

        {
          items: events,
          pagination: {
            page_size: size,
            total: events.total_count,
            sort:
          }
        }
      end

      private

      def order(sort)
        sorts = {
          'name__asc' => 'name ASC',
          'name__desc' => 'name DESC',
          'count_asc' => 'count ASC',
          'count_desc' => 'count DESC'
        }
        sorts[sort]
      end
    end
  end
end
