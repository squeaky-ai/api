# frozen_string_literal: true

require 'zlib'
require 'base64'
require 'securerandom'

# Pick up validated events from the events queue and
# store them in the database. The body is gzipped so
# that it doesn't take up too much space in Redis.
class EventsJob < ApplicationJob
  queue_as :default

  def perform(args)
    @message = extract_body(args)
    @site = Site.find_by(uuid: @message['viewer']['site_id'])

    recording = find_or_create_recording!
    update_recording!(recording)
    store_event!(recording)
  end

  # Seems to error without this, not sure why
  def jid=(args); end

  def event
    @message['value']
  end

  def event_type
    @message['key']
  end

  def viewer_id
    @message['viewer']['viewer_id']
  end

  def session_id
    @message['viewer']['session_id']
  end

  private

  def extract_body(args)
    zstream = Zlib::Inflate.new

    str = Base64.decode64(args)
    str = zstream.inflate(str)
    zstream.finish
    zstream.close

    JSON.parse(str)
  end

  def find_or_create_recording!
    @site.recordings.find_by(session_id: session_id) || Recording.create(
      site: @site,
      session_id: session_id,
      viewer_id: viewer_id
    )
  end

  def update_recording!(recording)
    if event_type == 'connected'
      recording.active = true
      recording.connected_at = event
    end

    if event_type == 'disconnected'
      recording.active = false
      recording.disconnected_at = event
    end

    if event_type == 'event' && event['type'] == Event::META
      attributes = format_event_for_stamp(recording)
      recording.update(attributes)
    end

    recording.save
  end

  def store_event!(recording)
    return unless event_type == 'event'

    Event.create(
      recording: recording,
      event_type: event['type'],
      data: event['data'],
      timestamp: event['timestamp']
    )
  end

  def format_event_for_stamp(recording)
    {
      locale: event['data']['locale'],
      viewport_x: event['data']['width'],
      viewport_y: event['data']['height'],
      useragent: event['data']['useragent'],
      page_views: recording.page_views << URI(event['data']['href']).path
    }
  end
end
