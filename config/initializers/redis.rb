# frozen_string_literal: true

Redis.current = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'))
