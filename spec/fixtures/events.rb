# frozen_string_literal: true

module Fixtures
  class Events
    def initialize(recording)
      @recording = recording
    end

    def timestamp
      now = (Time.now.to_f * 1000).to_i
      Faker::Number.between(from: now - 20_000, to: now)
    end

    def page_view
      Event.new(
        site_session_id: @recording.event_key,
        type: 'page_view',
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
        type: %w[click hover focus blur].sample,
        selector: 'body',
        time: 0,
        timestamp: timestamp
      )
    end

    def sample(count)
      count.times.map { [page_view, scroll, cursor, interaction].sample }
    end
  end
end
