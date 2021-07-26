# frozen_string_literal: true

module Fixtures
  class Events
    def initialize(recording)
      @recording = recording
    end

    def sample(count)
      count.times.map do |i|
        Event.new(
          event_type: [Event::FULL_SNAPSHOT, Event::INCREMENTAL_SNAPSHOT, Event::META].sample,
          data: {},
          recording: @recording,
          timestamp: (Time.now.to_i + 1) * 1000
        )
      end
    end
  end
end
