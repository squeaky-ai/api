# frozen_string_literal: true

module Types
  # Fetch all of the events from Redis
  class EventsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      session_id = object.object[:id]

      Event.new(site_id, session_id).list
    end
  end
end
