# frozen_string_literal: true

require 'zlib'
require 'base64'
require 'securerandom'

# Pick up validated events from the events queue and
# store them in DynamoDB. Page views should be placed onto
# the recordings queue to be indexed into elasticsearch
class EventsJob < ApplicationJob
  queue_as :default

  def perform(args)
    message = extract_body(args)

    @event = message['event']
    @viewer_id = message['viewer']['viewer_id']
    @session_id = message['viewer']['session_id']

    @site = Site.find_by(uuid: message['viewer']['site_id'])

    recording = find_or_create_recording!
    store_event!(recording)
    index_to_elasticsearch!(recording)
  end

  # TODO
  def jid=(args); end

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
    @site.recordings.find_by(session_id: @session_id) || Recording.create(
      site: @site,
      session_id: @session_id,
      viewer_id: @viewer_id,
      locale: 'TODO',
      useragent: 'TODO'
    )
  end

  def store_event!(recording)
    Event.create(
      recording: recording,
      event_type: @event['type'],
      data: @event['data'],
      timestamp: @event['timestamp']
    )
  end

  def index_to_elasticsearch!(recording)
    # Don't both reindexing unless they change page so that
    # we don't spam ES
    return unless @event['type'] == Event::META

    # We don't want those getting indexed
    doc = recording.to_h.except(:tags, :notes, :events)

    # Upsert the entire recording hash using a key that
    # we can easilly reference later when we come to upsert
    # again
    SearchClient.update(
      index: Recording::INDEX,
      id: "#{@site.id}_#{@viewer_id}_#{@session_id}",
      retry_on_conflict: 3,
      body: {
        doc: doc,
        doc_as_upsert: true
      }
    )
  end
end
