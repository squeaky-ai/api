# frozen_string_literal: true

require 'securerandom'

module Fixtures
  class Events
    def initialize(recording)
      @recording = recording
    end

    def page_view
      Event.new(
        site_session_id: @recording.event_key,
        event_id: SecureRandom.uuid,
        type: 'page_view',
        path: '/',
        viewport_x: 0,
        viewport_y: 0,
        locale: 'en-gb',
        useragent: Faker::Internet.user_agent,
        time: 0,
        timestamp: 0
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
        timestamp: 0
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
        timestamp: 0
      )
    end

    def interaction
      Event.new(
        site_session_id: @recording.event_key,
        event_id: SecureRandom.uuid,
        type: %w[click hover focus blur].sample,
        selector: 'body',
        time: 0,
        timestamp: 0
      )
    end

    def sample(count)
      count.times.map { [page_view, scroll, cursor, interaction].sample }
    end
  end
end
