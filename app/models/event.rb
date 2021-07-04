# frozen_string_literal: true

# Helper class for getting the recording events in
# and out of Redis
class Event
  def initialize(site_id, session_id)
    @site_id = site_id
    @session_id = session_id
  end

  def list
    Redis.current
         .lrange(key, 0, -1)
         .map { |e| JSON.parse(e) }
         .sort_by { |e| e['timestamp'] }
  end

  def push!(events)
    Redis.current.rpush(key, events.map(&:to_json))
  end

  private

  def key
    "recording::events::#{@site_id}::#{@session_id}"
  end
end
