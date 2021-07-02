# frozen_string_literal: true

require 'securerandom'

module Fixtures
  class Events
    def initialize(recording)
      @recording = recording
    end

    def timestamp
      now = (Time.now.to_f * 1000).to_i
      Faker::Number.between(from: now - 20_000, to: now)
    end

    def pageview
      Event.new(
        site_session_id: @recording.event_key,
        event_id: SecureRandom.uuid,
        type: 'pageview',
        path: '/',
        viewport_x: 0,
        viewport_y: 0,
        locale: 'en-gb',
        useragent: Faker::Internet.user_agent,
        time: 0,
        timestamp: timestamp
      )
    end

    def scroll
      Event.new(
        site_session_id: @recording.event_key,
        event_id: SecureRandom.uuid,
        type: 'scroll',
        x: 0,
        y: 0,
        time: 0,
        timestamp: timestamp
      )
    end

    def cursor
      Event.new(
        site_session_id: @recording.event_key,
        event_id: SecureRandom.uuid,
        type: 'cursor',
        x: 0,
        y: 0,
        time: 0,
        timestamp: timestamp
      )
    end

    def interaction
      Event.new(
        site_session_id: @recording.event_key,
        event_id: SecureRandom.uuid,
        type: %w[click hover focus blur].sample,
        selector: 'body',
        time: 0,
        timestamp: timestamp
      )
    end

    def sample(count)
      count.times.map { [pageview, scroll, cursor, interaction].sample }
    end
  end
end
