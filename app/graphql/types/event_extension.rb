# frozen_string_literal: true

module Types
  # Events need to be stringified as they can't realistically
  # be typed in the schema
  class EventExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      recording_id = object.object[:id]

      Event.where(recording_id: recording_id).map { |e| format_event(e) }.to_json
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
  end
end
