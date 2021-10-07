# frozen_string_literal: true

class InvalidRecording < StandardError
end

# Pick up messages from SQS and save the recordings
# that are temporarily stored in Redis
class RecordingSaveJob < ApplicationJob
  queue_as :default

  before_perform do |job|
    @args = parse_arguments(job.arguments)
    @site = Site.find_by(uuid: @args['site_id'])

    validate!
  end

  after_perform { clean_up }

  rescue_from(InvalidRecording) { Rails.logger.warn 'Recording was invalid, ignoring' }

  rescue_from(StandardError) { Rails.logger.error 'Recording failed to save' }

  def perform(*_args, **_kwargs)
    ActiveRecord::Base.transaction do
      visitor = persist_visitor!
      recording = persist_recording!(visitor)

      persist_events!(recording)
      persist_pageviews!(recording)
      index_to_elasticsearch!(recording, visitor)
    end

    Rails.logger.info 'Recording saved'
  end

  private

  def parse_arguments(arguments)
    JSON.parse(arguments[0])
  end

  def index_to_elasticsearch!(recording, visitor)
    return if recording.deleted

    SearchClient.bulk(
      body: [
        {
          index: {
            _index: Recording::INDEX,
            _id: recording.id,
            data: recording.to_h
          }
        },
        {
          index: {
            _index: Visitor::INDEX,
            _id: visitor.id,
            data: visitor.to_h
          }
        }
      ]
    )
  end

  def persist_visitor!
    if external_attributes['id']
      visitor = Visitor
                .joins(:recordings)
                .where("visitors.external_attributes->>'id' = ? AND recordings.site_id = ?", external_attributes['id'], @site.id)
                .first

      return visitor if visitor
    end

    visitor = Visitor.find_or_create_by(visitor_id: @args['visitor_id'])

    visitor.external_attributes = external_attributes
    visitor.save!

    visitor
  end

  def persist_recording!(visitor)
    # Warning: this is prone to race conditions
    recording = Recording.find_or_create_by(session_id: @args['session_id'])

    if recording.new_record?
      recording.visitor_id = visitor.id
      recording.site_id = @site.id
      recording.deleted = soft_delete?
      recording.locale = redis_recording['locale']
      recording.useragent = redis_recording['useragent']
      recording.viewport_x = redis_recording['width']
      recording.viewport_y = redis_recording['height']
      recording.connected_at = redis_events.first['timestamp']
    end

    recording.disconnected_at = redis_events.last['timestamp']

    recording.save!
    recording
  end

  def persist_events!(recording)
    now = Time.now
    # Batch insert all of the events. PG has a limit of
    # 65535 placeholders and some users spend bloody ages on
    # the site, so it's best to chunk all of these up so they
    # don't hit the limit
    redis_events.each_slice(100) do |slice|
      items = slice.map do |s|
        {
          event_type: s['type'],
          data: s['data'],
          timestamp: s['timestamp'],
          recording_id: recording.id,
          created_at: now,
          updated_at: now
        }
      end

      Event.insert_all!(items)
    end
  end

  def persist_pageviews!(recording)
    now = Time.now
    page_views = []

    redis_pageviews.each do |page|
      prev = page_views.last
      path = page['path']
      timestamp = page['timestamp']

      next if prev && prev[:url] == path

      prev[:exited_at] = timestamp if prev

      page_views.push(
        url: path,
        entered_at: timestamp,
        exited_at: timestamp,
        recording_id: recording.id,
        created_at: now,
        updated_at: now
      )
    end

    page_views.last[:exited_at] = recording.disconnected_at

    Page.insert_all!(page_views)
  end

  def validate!
    # I guess this is possible
    raise InvalidRecording, 'Recording has no events' if redis_events.size.zero?

    # Probably a bot that bounced before the meta event could fire
    raise InvalidRecording, 'Recording has no page views' if redis_pageviews.size.zero?
  end

  def soft_delete?
    # Recorings less than 3 seconds aren't worth viewing but are
    # good for analytics
    return true if (redis_events.last['timestamp'] - redis_events.first['timestamp']) < 3000

    # Recordings without any user interaction are also not worth
    # watching, and is likely a bot
    return true unless redis_events.any? { |event| event['type'] == 3 && event['data']['source'] }

    false
  end

  def external_attributes
    identify = redis_recording['identify']

    JSON.parse(identify || '{}').reduce({}) do |memo, (key, value)|
      memo[key] = value.to_s
      memo
    end
  end

  def redis_key(prefix)
    "#{prefix}::#{@args['site_id']}::#{@args['session_id']}"
  end

  def redis_events
    key = redis_key('events')
    @redis_events ||= Redis.current.lrange(key, 0, -1).map { |i| JSON.parse(i) }.sort_by { |e| e['timestamp'] }
  end

  def redis_recording
    key = redis_key('recording')
    @redis_recording ||= Redis.current.hgetall(key)
  end

  def redis_pageviews
    key = redis_key('pageviews')
    @redis_pageviews ||= Redis.current.lrange(key, 0, -1).map { |i| JSON.parse(i) }
  end

  def clean_up
    keys = %w[events recording pageviews]
    keys.each { |k| Redis.current.del(redis_key(k)) }
  end
end
