# frozen_string_literal: true

require 'uri'

# Format the S3 Kinesis dump into something useful
class Session
  attr_reader :recording,
              :pageviews,
              :external_attributes,
              :events,
              :site_id,
              :visitor_id,
              :session_id

  def initialize(bucket, key)
    @events = []
    @pageviews = []
    @recording = {}
    @external_attributes = {}

    fetch_and_process_events(bucket, key)
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
    recording['referrer']
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

  def fetch_and_process_events(bucket, key)
    client = Aws::S3::Client.new
    response = client.get_object(bucket: bucket, key: key)

    events = response
             .body
             .read
             .split(',')
             .map { |b| JSON.parse(Zlib::Inflate.inflate(Base64.decode64(b))) }
             .sort_by { |e| e['value']['timestamp'] }

    extract_and_set_visitor_details(events)
    extract_and_set_events(events)
  end

  def extract_and_set_visitor_details(events)
    parts = events.find { |e| !e['visitor'].nil? }['visitor'].split('::')

    @site_id = parts[0]
    @visitor_id = parts[1]
    @session_id = parts[2]
  end

  def extract_and_set_events(events)
    events.each do |event|
      case event['key']
      when 'recording'
        @recording = event['value']['data']
      when 'identify'
        @external_attributes = event['value']['data'].transform_values(&:to_s)
      when 'pageview'
        uri = URI(event['value']['data']['href'])
        @pageviews.push('path' => uri.path, 'timestamp' => event['value']['timestamp'])
      when 'event'
        @events.push(event['value'])
      end
    end
  end
end
