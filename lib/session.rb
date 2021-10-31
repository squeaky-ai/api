# frozen_string_literal: true

# A wrapper around the raw session data that is stored
# in Redis
class Session
  def initialize(args)
    @args = args
  end

  def identify
    key = redis_key('identify')
    @identify ||= Redis.current.get(key)
  end

  def events
    key = redis_key('events')
    @events ||= parse_and_sort_events(Redis.current.lrange(key, 0, -1))
  end

  def recording
    key = redis_key('recording')
    @recording ||= Redis.current.hgetall(key)
  end

  def pageviews
    key = redis_key('pageviews')
    @pageviews ||= parse_and_sort_events(Redis.current.lrange(key, 0, -1))
  end

  def external_attributes
    JSON.parse(identify || '{}').transform_values(&:to_s)
  end

  def clean_up!
    keys = %w[events recording pageviews identify]
    keys.each { |k| Redis.current.del(redis_key(k)) }
  end

  def connected_at
    return 0 unless events?

    events.first['timestamp']
  end

  def disconnected_at
    return 0 unless events?

    events.last['timestamp']
  end

  def duration
    disconnected_at - connected_at
  end

  def events?
    !events.empty?
  end

  def pageviews?
    !pageviews.empty?
  end

  def interaction?
    events.any? { |event| event['type'] == 3 && event['data']['source'] }
  end

  private

  def redis_key(prefix)
    "#{prefix}::#{@args[:site_id]}::#{@args[:visitor_id]}::#{@args[:session_id]}"
  end

  def parse_and_sort_events(events)
    events.map { |i| JSON.parse(i) }.sort_by { |e| e['timestamp'] }
  end
end
