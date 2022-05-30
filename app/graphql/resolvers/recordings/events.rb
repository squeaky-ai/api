# frozen_string_literal: true

# TODO: Remove either postgres of clickhouse, whichever is victorious

module Resolvers
  module Recordings
    class Events < Resolvers::Base
      type Types::Recordings::Events, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 250

      def resolve(page:, size:)
        if ClickHouseMigration.read?(object.site_id)
          events_from_clickhouse(page, size)
        else
          events_from_postgres(page, size)
        end
      end

      private

      # ClickHouse stuff

      def events_from_clickhouse(page, size)
        events = ClickHouse::Event
                 .where(recording_id: object.id)
                 .order('timestamp asc')
                 .limit(size)
                 .offset(size * (page - 1))
                 .select_all

        {
          items: events.map { |e| format_clickhouse_event(e) },
          pagination: clickhouse_pagination
        }
      end

      def format_clickhouse_event(event)
        {
          id: event['uuid'],
          type: event['type'],
          timestamp: event['timestamp'],
          data: JSON.parse(event['data'])
        }.to_json
      end

      def clickhouse_pagination
        total_events = ClickHouse::Event
                       .where(recording_id: object.id)
                       .select('count(*) total')
                       .select_one
        {
          per_page: arguments[:size],
          item_count: total_events['total'],
          current_page: arguments[:page],
          total_pages: (total_events['total'].to_f / arguments[:size]).ceil
        }
      end

      # Postgres stuff

      def events_from_postgres(page, size)
        events = Event
                 .select('id, data, event_type as type, timestamp')
                 .where(recording_id: object.id)
                 .order('timestamp asc')
                 .page(page)
                 .per(size)

        {
          items: events.map(&:to_json),
          pagination: postgres_pagination(events)
        }
      end

      def postgres_pagination(events)
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
