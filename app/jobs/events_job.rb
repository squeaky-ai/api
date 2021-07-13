# frozen_string_literal: true

require 'zlib'
require 'base64'
require 'securerandom'

# Pick up validated events from the events queue and
# store them in DynamoDB. Page views should be placed onto
# the recordings queue to be indexed into elasticsearch
class EventsJob < ApplicationJob
  queue_as :events

  self.queue_adapter = :amazon_sqs

  def perform(args)
    message = extract_body(args)

    @viewer = message['viewer']
    @events = message['events']

    @site = Site.find_by(uuid: message['viewer']['site_id'])

    store_events!
    store_recording!
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

  def session_id
    @viewer['session_id']
  end

  def viewer_id
    @viewer['viewer_id']
  end

  def store_events!
    events = @events.map do |event|
      {
        event_id: SecureRandom.uuid,
        **event
      }
    end

    Event.new(@site.id, session_id).push!(events)
  end

  def store_recording!
    event = @events.find { |e| e['type'] == 'pageview' }

    return unless event

    recording = @site.recordings.find_by(session_id: session_id)

    recording = recording ? stamp_existing_recording!(recording, event) : create_new_recording!(event)

    index_to_elasticsearch!(recording)
  end

  # The only things that change between sessions are the
  # pages and the disconnected_at
  def stamp_existing_recording!(recording, event)
    recording.stamp(event['path'], event['timestamp'])
  end

  # New recordings share the same connected_at and
  # disconnected_at and only the disconnected_at will be
  # updated with subsequent page views
  def create_new_recording!(event)
    # The gateway supplies the date as milliseconds
    timestamp = DateTime.strptime(event['timestamp'].to_s, '%Q')

    Recording.create(
      site: @site,
      session_id: session_id,
      viewer_id: viewer_id,
      locale: event['locale'],
      page_views: [event['path']],
      useragent: event['useragent'],
      viewport_x: event['viewport_x'],
      viewport_y: event['viewport_y'],
      connected_at: timestamp,
      disconnected_at: timestamp
    )
  end

  # Upsert te entire recording hash using a key that
  # we can easilly reference later when we come to upsert
  # again
  def index_to_elasticsearch!(recording)
    # We don't want those getting indexed
    doc = recording.to_h.except(:tags, :notes)

    SearchClient.update(
      index: Recording::INDEX,
      id: "#{@site.id}_#{viewer_id}_#{session_id}",
      body: {
        doc: doc,
        doc_as_upsert: true
      }
    )
  end
end
