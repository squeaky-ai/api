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
      required: %w[mouse_x mouse_y scroll_x scroll_y position],
      properties: {
        mouse_x: { type: 'integer' },
        mouse_y: { type: 'integer' },
        scroll_x: { type: 'integer' },
        scroll_y: { type: 'integer' },
        position: { type: 'integer' }
      }
    }.freeze

    def initialize(context)
      @site_id = context[:site_id]
      @viewer_id = context[:viewer_id]
      @session_id = context[:session_id]
    end

    def add(event)
      Redis.current.rpush(key, event.to_json)
    end

    def list(start, stop)
      # Redis includes the right element, so subtract 1
      results = Redis.current.lrange(key, start, stop - 1)
      results.map { |r| JSON.parse(r) }
    end

    def size
      Redis.current.llen(key)
    end

    def self.validate!(event)
      JSON::Validator.validate!(Event::SCHEMA, event, strict: true)
      event
    rescue JSON::Schema::ValidationError => e
      Rails.logger.warn e
      raise
    end

    private

    def key
      "event:#{@site_id}:#{@session_id}:#{@viewer_id}"
    end
  end
end
