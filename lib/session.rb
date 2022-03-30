# frozen_string_literal: true

require 'uri'

# Format the Redis list into something useful
class Session
  attr_reader :recording,
              :pageviews,
              :sentiments,
              :nps,
              :external_attributes,
              :events,
              :site_id,
              :visitor_id,
              :session_id

  def initialize(message)
    @events = []
    @pageviews = []
    @recording = {}
    @sentiments = []
    @nps = nil
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

  def timezone
    recording['timezone']
  end

  def country_code
    Timezone.get_country_code(timezone)
  end

  def browser
    UserAgent.parse(useragent).browser
  end

  def device_type
    UserAgent.parse(useragent).mobile? ? 'Mobile' : 'Computer'
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

  def clean_up!
    Cache.redis.del("events::#{@site_id}::#{@visitor_id}::#{@session_id}")
  end

  private

  def fetch_and_process_events
    key = "events::#{@site_id}::#{@visitor_id}::#{@session_id}"

    events = Cache
             .redis
             .lrange(key, 0, -1)
             .map { |e| parse_event_and_ignore_errors(e) }
             .filter { |e| !e.nil? }
             .sort_by { |e| e['value']['timestamp'] }

    extract_and_set_events(events)
  end

  def extract_and_set_events(events)
    events.each do |event|
      case event['key']
      when 'recording'
        handle_recording_event(event)
      when 'identify'
        handle_identify_event(event)
      when 'pageview'
        handle_pageview_event(event)
      when 'event'
        handle_event(event)
      when 'sentiment'
        handle_sentiment(event)
      when 'nps'
        handle_nps(event)
      end
    end
  end

  def handle_recording_event(event)
    event['value']['data'].each { |k, v| @recording[k] = v unless @recording[k] }
  end

  def handle_identify_event(event)
    event['value']['data'].each { |k, v| @external_attributes[k] = v.to_s unless @external_attributes[k] }
  end

  def handle_pageview_event(event)
    uri = URI(event['value']['data']['href'])
    @pageviews.push('path' => uri.path, 'timestamp' => event['value']['timestamp'])
  end

  def handle_event(event)
    @events.push(event['value'])
  end

  def handle_sentiment(event)
    score = event['value']['data']['score']
    comment = event['value']['data']['comment']
    @sentiments.push(score:, comment:)
  end

  def handle_nps(event)
    data = event['value']['data']

    @nps = {
      score: data['score'],
      comment: data['comment'].presence,
      contact: data['contact'],
      email: data['email'].presence
    }
  end

  def parse_event_and_ignore_errors(event)
    JSON.parse!(event)
  rescue JSON::ParserError => e
    Rails.logger.warn "Failed to parse JSON #{e}"
    nil
  end
end
