# frozen_string_literal: true

module Types
  # Events need to be stringified as they can't realistically
  # be typed in the schema. You also can't load them all in one
  # go so they need to be streamed in
  class EventExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:page, Integer, required: false, default_value: 1, description: 'The page of results to get')
      field.argument(:size, Integer, required: false, default_value: 250, description: 'The page size')
    end

    def resolve(object:, arguments:, **_rest)
      recording_id = object.object[:id]

      events = Event
               .where(recording_id: recording_id)
               .order('timestamp asc')
               .page(arguments[:page])
               .per(arguments[:size])

      {
        items: events.map { |e| format_event(e) }.to_json,
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
        page_size: arguments[:size],
        page_count: arguments[:page],
        total: events.total_count
      }
    end
  end
end
