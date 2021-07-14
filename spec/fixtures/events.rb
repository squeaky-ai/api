# frozen_string_literal: true

require 'securerandom'

module Fixtures
  class Events
    def initialize(recording)
      @recording = recording
    end

    def sample(count)
      count.times.map do
        Event.new(
          event_id: SecureRandom.uuid,
          type: [Event::FULL_SNAPSHOT, Event::INCREMENTAL_SNAPSHOT, Event::META],
          data: {},
          recording: @recording,
          timestamp: Time.now.to_i * 1000
        )
      end
    end
  end
end
