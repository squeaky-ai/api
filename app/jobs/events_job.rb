# frozen_string_literal: true

require 'securerandom'

# Pick up validated events from the events queue and
# store them in DynamoDB. Page views should be placed onto
# the recordings queue to be indexed into elasticsearch
class EventsJob < ApplicationJob
  queue_as :events

  self.queue_adapter = :amazon_sqs

  def perform(args)
    message = JSON.parse(args)

    @client = Aws::DynamoDB::Client.new

    @site_id = message['site_id']
    @session_id = message['session_id']
    @events = message['events']

    store_events!
    store_recording!
  end

  private

  # Insert a batch of events into Dynamo for the best
  # performance. Although we never use the event_id it is
  # used to satisfy the standard range key. When querying
  # events we use the timestamps LSI to ensure we get the
  # events in ascending order, however there is too great
  # of a risk of timestamps colliding.
  def store_events!
    @client.batch_write_item(
      request_items: {
        Event.table_name => @events.map do |event|
          {
            put_request: {
              item: {
                site_session_id: "#{@site_id}_#{@session_id}",
                event_id: SecureRandom.uuid,
                **event
              }
            }
          }
        end
      }
    )
  end

  # Make use of some DynamoDB magic so that we don't need
  # to first read the item, then write based on the result.
  # Everything can be done in a single atomic transaction
  # which should make it thread safe, as well as much
  # faster.
  def store_recording!
    event = @events.find { |e| e['type'] == 'page_view' }

    return unless event

    @client.update_item(
      table_name: Recording.table_name,
      key: {
        site_id: @site_id,
        session_id: @session_id
      },
      update_expression: 'SET locale = :locale, ' \
                         'viewer_id = :viewer_id, ' \
                         'start_page = if_not_exists(start_page, :path), ' \
                         'exit_page = :path, ' \
                         'useragent = :useragent, ' \
                         'viewport_x = :viewport_x, ' \
                         'viewport_y = :viewport_y, ' \
                         'page_views = list_append(if_not_exists(page_views, :empty_list), :page_view), ' \
                         'connected_at = if_not_exists(connected_at, :connected_at), ' \
                         'disconnected_at = :disconnected_at',
      expression_attribute_values: {
        ':locale': event['locale'],
        ':path': event['path'],
        ':page_view': [event['path']],
        ':viewer_id': event['viewer_id'],
        ':useragent': event['useragent'],
        ':viewport_x': event['viewport_x'],
        ':viewport_y': event['viewport_y'],
        ':connected_at': event['timestamp'],
        ':disconnected_at': event['timestamp'],
        ':empty_list': []
      }
    )

    sync_recording!
  end

  # Sync the recently updated recording into elasticsearch
  # so that appears correctly in the UI. It would be nice
  # to use the return value from the update_item, but at
  # present DynamoDB does not support RETURN_ALL, only new
  # or updated
  def sync_recording!
    key = { site_id: @site_id, session_id: @session_id }
    # Best to use consistent read here as it was just updated
    recording = Recording.find_with_opts(key: key, consistent_read: true)

    SearchClient.update(
      index: Recording::INDEX,
      id: "#{recording.site_id}_#{recording.viewer_id}_#{recording.session_id}",
      body: {
        doc: recording.serialize,
        doc_as_upsert: true
      }
    )
  end
end
