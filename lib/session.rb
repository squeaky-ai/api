# frozen_string_literal: true

require 'uri'

# Format the Redis list into something useful
class Session
  attr_reader :recording,
              :pageviews,
              :external_attributes,
              :events,
              :site_id,
              :visitor_id,
              :session_id

  def initialize(message)
    @events = []
    @pageviews = []
    @recording = {}
    @external_attributes = {}

    @site_id = message[:site_id]
    @visitor_id = message[:visitor_id]
    @session_id = message[:session_id]

    fetch_and_process_events
  end

  def locale
    recording['locale']
  end

  def useragent
    recording['useragent']
  end

  def viewport_x
    recording['viewport_x'].to_i
  end

  def viewport_y
    recording['viewport_y'].to_i
  end

  def device_x
    recording['device_x'].to_i
  end

  def device_y
    recording['device_y'].to_i
  end

  def referrer
    recording['referrer'].presence
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

  def recording?
    keys = %w[locale viewport_x viewport_x device_x device_y useragent]
    keys.all? { |k| !@recording[k].nil? }
  end

  def interaction?
    events.any? { |event| event['type'] == 3 && event['data']['source'] }
  end

  private

  def fetch_and_process_events
    key = "events::#{@site_id}::#{@visitor_id}::#{@session_id}"

    events = Redis
             .current
             .lrange(key, 0, -1)
             .map { |e| JSON.parse(e) }
             .sort_by { |e| e['value']['timestamp'] }

    extract_and_set_events(events)
  end

  def extract_and_set_events(events)
    events.each do |event|
      case event['key']
      when 'recording'
        event['value']['data'].each { |k, v| @recording[k] = v unless @recording[k] }
      when 'identify'
        event['value']['data'].each { |k, v| @external_attributes[k] = v.to_s unless @external_attributes[k] }
      when 'pageview'
        uri = URI(event['value']['data']['href'])
        @pageviews.push('path' => uri.path, 'timestamp' => event['value']['timestamp'])
      when 'event'
        @events.push(event['value'])
      end
    end
  end
end
