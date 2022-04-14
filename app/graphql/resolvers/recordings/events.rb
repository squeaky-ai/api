# frozen_string_literal: true

module Resolvers
  module Recordings
    class Events < Resolvers::Base
      type Types::Recordings::Events, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 100

      def resolve(page:, size:)
        Stats.timer('list_events') do
          events = Event
                   .select('id, data, event_type as type, timestamp')
                   .where(recording_id: object.id)
                   .order('timestamp asc')
                   .page(page)
                   .per(size)

          {
            items: events.map(&:to_json),
            pagination: pagination(events, arguments)
          }
        end
      end

      private

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
