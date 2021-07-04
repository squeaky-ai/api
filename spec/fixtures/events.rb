# frozen_string_literal: true

require 'securerandom'

module Fixtures
  class Events
    def pageview
      {
        'event_id' => SecureRandom.uuid,
        'type' => 'pageview',
        'path' => '/',
        'viewport_x' => 0,
        'viewport_y' => 0,
        'locale' => 'en-gb',
        'useragent' => Faker::Internet.user_agent,
        'timestamp' => timestamp
      }
    end

    def scroll
      {
        'event_id' => SecureRandom.uuid,
        'type' => 'scroll',
        'x' => 0,
        'y' => 0,
        'timestamp' => timestamp
      }
    end

    def cursor
      {
        'event_id' => SecureRandom.uuid,
        'type' => 'cursor',
        'x' => 0,
        'y' => 0,
        'timestamp' => timestamp
      }
    end

    def visibility
      {
        'event_id' => SecureRandom.uuid,
        'type' => 'visibility',
        'visibile' => [true, false].sample,
        'timestamp' => timestamp
      }
    end

    def interaction
      {
        'event_id' => SecureRandom.uuid,
        'type' => %w[click hover focus blur].sample,
        'selector' => 'body',
        'node' => '',
        'timestamp' => timestamp
      }
    end

    def snapshot
      {
        'event_id' => SecureRandom.uuid,
        'type' => 'snapshot',
        'event' => %w[initialize applyChanged].sample,
        'snapshot' => '',
        'timestamp' => timestamp
      }
    end

    def sample(count)
      count.times.map { [pageview, scroll, cursor, interaction].sample }
    end

    def of_type(types)
      types.map { |t| send(t) }
    end

    def timestamp
      now = (Time.now.to_f * 1000).to_i
      Faker::Number.between(from: now - 20_000, to: now)
    end
  end
end
