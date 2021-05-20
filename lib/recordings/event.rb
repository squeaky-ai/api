# frozen_string_literal: true

require 'json-schema'

module Recordings
  # Validate that incoming events from the websocket match
  # the above schema before they are handed over to the job
  class Event
    SCHEMA = {
      type: 'object',
      required: %w[
        href
        locale
        position
        useragent
        timestamp
        mouse_x
        mouse_y
        scroll_x
        scroll_y
        viewport_x
        viewport_y
      ],
      properties: {
        href: { type: 'string' },
        locale: { type: 'string' },
        position: { type: 'integer' },
        useragent: { type: 'string' },
        timestamp: { type: 'integer' },
        mouse_x: { type: 'integer' },
        mouse_y: { type: 'integer' },
        scroll_x: { type: 'integer' },
        scroll_y: { type: 'integer' },
        viewport_x: { type: 'integer' },
        viewport_y: { type: 'integer' }
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
