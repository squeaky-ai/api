# frozen_string_literal: true

require 'json-schema'

module Recordings
  # Validate that the incoming event from the websocket
  # matches the above schema before they are handed over
  # to the job. Also offer methods to get and receive the
  # events from redis
  class Event
    SCHEMA = {
      type: 'object',
      required: %w[path locale useragent viewport_x viewport_y events],
      properties: {
        path: { type: 'string' },
        locale: { type: 'string' },
        useragent: { type: 'string' },
        viewport_x: { type: 'integer' },
        viewport_y: { type: 'integer' },
        events: {
          type: 'array',
          items: {
            type: 'object',
            oneOf: [
              {
                # Covers: InteractionEvent
                properties: {
                  type: { type: 'string' },
                  selector: { type: 'string' },
                  time: { type: 'integer' },
                  timestamp: { type: 'interger' }
                },
                required: %w[type selector time timestamp]
              },
              {
                # Covers: ScrollEvent | CursorEvent
                properties: {
                  type: { type: 'string' },
                  x: { type: 'integer' },
                  y: { type: 'integer' },
                  time: { type: 'integer' },
                  timestamp: { type: 'interger' }
                },
                required: %w[type x y time timestamp]
              }
            ]
          }
        }
      }
    }.freeze

    def self.validate!(event)
      JSON::Validator.validate!(Event::SCHEMA, event, strict: true)
      event
    rescue JSON::Schema::ValidationError => e
      Rails.logger.warn e
      raise
    end
  end
end
