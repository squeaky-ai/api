# frozen_string_literal: true

# TODO: Remove either postgres of clickhouse, whichever is victorious

module Resolvers
  module Recordings
    class Events < Resolvers::Base
      type Types::Recordings::Events, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 250

      def resolve_with_timings(page:, size:)
        events = Event
                 .select('id, data, event_type as type, timestamp')
                 .where(recording_id: object.id)
                 .order('timestamp asc')
                 .page(page)
                 .per(size)

        {
          items: events.map(&:to_json),
          pagination: pagination(events)
        }
      end

      private

      def pagination(events)
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
