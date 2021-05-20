# frozen_string_literal: true

require 'json-schema'

module Recordings
  # Validate that incoming page view event from the websocket
  # matches the above schema before they are handed over to
  # the job
  class PageView
    SCHEMA = {
      type: 'object',
      required: %w[href locale useragent viewport_x viewport_y],
      properties: {
        href: { type: 'string' },
        locale: { type: 'string' },
        useragent: { type: 'string' },
        viewport_x: { type: 'integer' },
        viewport_y: { type: 'integer' }
      }
    }.freeze

    def self.validate!(event)
      JSON::Validator.validate!(SCHEMA, event, strict: true)
      event
    rescue JSON::Schema::ValidationError => e
      Rails.logger.warn e
      raise
    end
  end
end
