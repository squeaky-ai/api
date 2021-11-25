# frozen_string_literal: true

module Types
  module Recordings
    class Events < Resolvers::Base
      type Types::Recordings::Events, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 250

      def resolve(page:, size:)
        events = Event
                 .where(recording_id: object.id)
                 .order('timestamp asc')
                 .page(page)
                 .per(size)

        {
          items: events.map { |e| format_event(e).to_json },
          pagination: pagination(events, arguments)
        }
      end

      private

      def format_event(event)
        {
          id: event.id,
          data: event.data,
          type: event.event_type,
          timestamp: event.timestamp
        }
      end

      def pagination(events, arguments)
        {
          per_page: arguments[:size],
          item_count: events.total_count,
          current_page: arguments[:page],
          total_pages: events.total_pages
        }
      end
    end
  end
end
