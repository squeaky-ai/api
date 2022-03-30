# frozen_string_literal: true

class Cache
  class << self
    def redis
      @redis ||= Redis.new
    end
  end
end
