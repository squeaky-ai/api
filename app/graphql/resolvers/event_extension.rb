# frozen_string_literal: true

module Types
  class EventExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:page, Integer, required: false, default_value: 1)
      field.argument(:size, Integer, required: false, default_value: 250)
    end

    def resolve(object:, arguments:, **_rest)
      recording_id = object.object[:id]

      events = Event
               .where(recording_id: recording_id)
               .order('timestamp asc')
               .page(arguments[:page])
               .per(arguments[:size])

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
