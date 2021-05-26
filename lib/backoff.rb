# frozen_string_literal: true

# Provide a way of backing off users requests with
# an identifier. The value is a hash that contains
# the limit so we can set limits on a per-key basis
class Backoff
  def initialize(identifier, limit = 10)
    @identifier = identifier
    @limit = limit
  end

  def incr!
    value = Redis.current.hgetall(key)

    raise BackoffExceeded if exceeded?(value)

    if value.empty?
      Redis.current.hset(key, { count: 0, limit: @limit })
    else
      Redis.current.hincrby(key, 'count', 1)
    end
  end

  def clear!
    Redis.current.del(key)
  end

  def exceeded?(value = nil)
    value ||= Redis.current.hgetall(key)
    return false if value.empty?

    value['count'] >= value['limit']
  end

  private

  def key
    "backoff:#{@identifier}"
  end

  # An exception to throw when the limit has been exceeded
  # that we can catch in the GraphQL handler to throw a more
  # suitable error for the front end
  class BackoffExceeded < StandardError
    def initialize(msg = 'Backoff limit exceeded')
      super
    end
  end
end
