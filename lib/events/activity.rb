# typed: false
# frozen_string_literal: true

# This is adapted from the rrweb library so that the inactivity
# calculated here marries up with the replaying. The reason this
# is done here is because it's the only time where we have all
# the events in memory, and storing it allows us to filter and
# sort on the activity durations.

module Events
  class Activity
    MAX_SPEED = 25 # Same as /src/lib/replayer in the app
    SKIP_TIME_INTERVAL = 5 * 1000
    SKIP_TIME_THRESHOLD = 10 * 1000

    attr_accessor :inactivity

    def initialize(events)
      @events = events_with_delay(events)
      @skipping = false
      @skipping_speed = 1
      @next_user_interaction_event = nil
      @inactivity = []

      process_inactivity
    end

    def activity_duration
      inactive_periods = inactivity.map { |i| i[1] - i[0] }.sum
      events.last['timestamp'] - events.first['timestamp'] - inactive_periods
    end

    private

    attr_reader :events

    def events_with_delay(events)
      events.map { |event| add_delay(event, events.first['timestamp']) }
    end

    def process_inactivity
      events.each { |event| process_event(event) }

      # If the last event is inactivity then it will not
      # have an end, so it must be manually added
      inactivity.last.push(events.last['delay']) if inactivity.last&.size == 1
    end

    def process_event(event) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      if event == @next_user_interaction_event
        @next_user_interaction_event = nil
        @skipping_speed = 0
      end

      return if @next_user_interaction_event

      events.each do |evt|
        next if evt['timestamp'] <= event['timestamp']

        if user_interaction?(evt)
          @next_user_interaction_event = evt if evt['delay'] - event['delay'] > SKIP_TIME_THRESHOLD * @skipping_speed
          break
        end
      end

      return unless @next_user_interaction_event

      @skip_time = @next_user_interaction_event['delay'] - event['delay']
      @skipping_speed = [(@skip_time / SKIP_TIME_INTERVAL).round, MAX_SPEED].min

      if @skipping_speed.positive? && !@skipping
        inactivity.push([event['delay']])
        @skipping = true
      end

      if @skipping_speed.zero? && @skipping # rubocop:disable Style/GuardClause
        inactivity.last.push(event['delay'])
        @skipping = false
      end
    end

    def user_interaction?(event)
      return false unless event['type'] == Event::INCREMENTAL_SNAPSHOT

      event['data']['source'] > Event::IncrementalSource::MUTATION && event['data']['source'] <= Event::IncrementalSource::INPUT
    end

    def add_delay(event, baseline_time)
      if event['type'] == Event::INCREMENTAL_SNAPSHOT && event['data']['source'] == Event::IncrementalSource::MOUSE_MOVE
        first_offset = event['data']['positions'].first['timeOffset']
        first_timestamp = event['timestamp'] + first_offset
        event['delay'] = first_timestamp - baseline_time
      else
        event['delay'] = event['timestamp'] - baseline_time
      end

      event
    end
  end
end
