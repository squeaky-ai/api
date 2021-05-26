# frozen_string_literal: true

# Provide a way of backing off users requests with
# an identifier. The value is a hash that contains
# the limit so we can set limits on a per-key basis
class Backoff
  EXPIRY = 60 * 10

  def initialize(identifier, limit = 10)
    @identifier = identifier
    @limit = limit
  end

  def incr!
    value = Redis.current.hgetall(key)

    raise Errors::BackoffExceeded if exceeded?(value)

    if value.empty?
      create!
    else
      Rails.logger.info "Backing off #{@identifier} to #{value['count'] + 1}"
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

  def create!
    Redis.current.hset(key, { count: 0, limit: @limit })
    Redis.current.expire(key, EXPIRY)
  end
end
