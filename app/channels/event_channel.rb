# frozen_string_literal: true

require 'uri'

# The channel that's used for streaming in the events
# from sites
class EventChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "User connected #{current_visitor}"
  end

  # Site owners can add a snippet to the bottom of the page
  # that lets them identify users by providing an id, email,
  # or any other key/values. These are stored as JSON
  def identify(data)
    store_user_attributes(data)
  end

  # Single page sites do not close/reopen the connection every
  # time they navigate, so the script sends a fake page view
  # when the SPA modifies the path in the browser
  def pageview(data)
    store_page_view(data)
  end

  # Events are sent every 100ms or so and vary depending on
  # what's happened on screen. We store every event, but some
  # extra stuff is when the first event is send, as it includes
  # all of the page meta data
  def event(data)
    store_events(data)
    store_recording(data)
  end

  # When a recording is completed we publish as message to SQS for a
  # Lambda to pick up and do the heavy lifting. Because there's no way
  # to tell if a user has left, or if they're just navigating between
  # pages, we add 15 minutes (the max SQS supports), so that they've
  # got time to finish up
  def unsubscribed
    Rails.logger.info "User disconnected #{current_visitor}"

    client = Aws::SQS::Client.new(region: 'eu-west-1')

    client.send_message(
      queue_url: ENV.fetch('RECORDINGS_SAVE_QUEUE_URL', 'QUEUE_MISSING'),
      message_body: current_visitor.to_json
    )
  end

  private

  def redis_key(type)
    "#{type}::#{current_visitor[:site_id]}::#{current_visitor[:session_id]}"
  end

  def fetch_recording
    key = redis_key('recording')

    Redis.current.hgetall(key)
  end

  # Page views are stored as a comma seperated string in Redis
  # so the recording has to be fetched, and the new path appended
  # to the string
  def append_page_view(href)
    path = URI(href).path
    recording = fetch_recording
    page_views = recording['page_views']&.split(',') || []

    # If the same page appears twice in a row then they
    # probably refreshed, in which case we don't care
    page_views.push(path) if page_views.last != path

    page_views.compact.join(',')
  end

  def store_user_attributes(data)
    key = redis_key('recording')

    # Set the hash key "identify" with a stringified hash of
    # the user attributes. These are unvalidated by the front end
    # at the point, but will be checked before they are stored
    # in the database
    Redis.current.hset(key, 'identify', data['payload'].to_json)
  end

  def store_page_view(data)
    key = redis_key('recording')
    href = data['payload']['data']['href']

    Redis.current.hset(key, 'page_views', append_page_view(href))
  end

  def store_events(data)
    key = redis_key('events')

    # To make this faster, the events are an append-only list of
    # stringified events
    Redis.current.lpush(key, data['payload'].to_json)
  end

  def store_recording(data)
    key = redis_key('recording')

    # We only care about page views, other events won't have all
    # the necessary stuff
    return unless data['payload']['type'] == 4

    rec = data['payload']['data']

    params = {
      width: rec['width'],
      height: rec['height'],
      locale: rec['locale'],
      useragent: rec['useragent'],
      page_views: append_page_view(rec['href'])
    }

    Redis.current.hset(key, params)
  end
end
