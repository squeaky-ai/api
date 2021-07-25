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

    update_recording!
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
    # This very nearly was a disaster, the previous implementation
    # did find || create which shit the bed when two or more events
    # both tried to create a recording!
    @site.recordings.create_or_find_by!(session_id: session_id) { |r| r.viewer_id = viewer_id }
  end

  def update_recording!
    # TODO: I think it goes without saying that this is a bit messy!
    recording = find_or_create_recording!

    mark_active(recording) if event_type == 'connected'
    mark_inactive(recording) if event_type == 'disconnected'
    apply_event_args(recording) if event_type == 'event' && event['type'] == Event::META
    store_event!(recording)

    recording.save!
  end

  def mark_active(recording)
    recording.active = true
    recording.connected_at = event unless recording.connected_at
  end

  def mark_inactive(recording)
    recording.active = false
    recording.disconnected_at = event
  end

  def apply_event_args(recording)
    attributes = format_event_for_stamp(recording)
    recording.update(attributes)
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

  def store_event!(recording)
    return unless event_type == 'event'

    sql = <<-SQL
      UPDATE events
      SET events = array_append(events, ?)
      WHERE recording_id = ?;
    SQL

    entry = {
      type: event['type'],
      data: event['data'],
      timestamp: event['timestamp']
    }.to_json

    query = ActiveRecord::Base.sanitize_sql_array([sql, entry, recording.id])
    ActiveRecord::Base.connection.execute(query)
  end
end
