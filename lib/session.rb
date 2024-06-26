# frozen_string_literal: true

# Format the Redis list into something useful
class Session # rubocop:disable Metrics/ClassLength
  attr_reader :recording,
              :pageviews,
              :sentiments,
              :nps,
              :clicks,
              :custom_tracking,
              :external_attributes,
              :errors,
              :events,
              :scrolls,
              :cursors,
              :site_id,
              :visitor_id,
              :session_id

  def initialize(message)
    @events = []
    @pageviews = []
    @recording = {}
    @sentiments = []
    @clicks = []
    @nps = nil
    @custom_tracking = []
    @external_attributes = {}
    @errors = []
    @scrolls = []
    @cursors = []

    @site_id = message[:site_id]
    @visitor_id = message[:visitor_id]
    @session_id = message[:session_id]

    fetch_and_process_events
  end

  def events_key_prefix
    "#{site_id}/#{visitor_id}/#{session_id}"
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

  def utm_source
    recording['utm_source']
  end

  def utm_medium
    recording['utm_medium']
  end

  def utm_campaign
    recording['utm_campaign']
  end

  def utm_content
    recording['utm_content']
  end

  def utm_term
    recording['utm_term']
  end

  def gad
    recording['gad']
  end

  def gclid
    recording['gclid']
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
    events.any? { |event| event['type'] == Event::INCREMENTAL_SNAPSHOT && event['data']['source'] }
  end

  # 5 clicks within 1s
  def rage_clicked?
    # No point in checking if there's less than 5
    return false if clicks.size < 5

    timestamps = clicks.pluck('timestamp')

    timestamps.any? do |timestamp|
      from = timestamp
      to = timestamp + 1000

      timestamps.filter { |c| c.between?(from, to) }.size >= 5
    end
  end

  # Went back to a previous page within 7 seconds
  def u_turned?
    pages.each.with_index.any? do |page, index|
      prev_page = index.zero? ? nil : pages[index - 1] # (index[0] - 1) will wrap around
      next_page = pages[index + 1]

      if prev_page && next_page
        prev_page[:url] == next_page[:url] && page[:duration] < 7000
      else
        false
      end
    end
  end

  def exists?
    Recording.exists?(session_id: @session_id)
  end

  delegate :inactivity, to: :activity

  delegate :activity_duration, to: :activity

  def pages
    @pages ||= page_views
  end

  def active_events_count
    data_points = %i[clicks pageviews custom_tracking errors cursors]
    data_points.inject(0) { |sum, data_point| sum + send(data_point).size }
  end

  def clean_up!
    Cache.redis.del("events::#{site_id}::#{visitor_id}::#{session_id}")
  end

  private

  def fetch_and_process_events
    key = "events::#{site_id}::#{visitor_id}::#{session_id}"

    events = Cache
      .redis
      .lrange(key, 0, -1)
      .map { |e| parse_event_and_ignore_errors(e) }
      .filter { |e| !e.nil? }
      .sort_by { |e| e['value']['timestamp'] }

    extract_and_set_events(events)
  end

  def activity
    @activity ||= Events::Activity.new(events)
  end

  def extract_and_set_events(events) # rubocop:disable Metrics/CyclomaticComplexity
    events.each do |event|
      next if ignore_event?(event['value'])

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
      when 'error'
        handle_error(event)
      when 'custom'
        handle_custom(event)
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
    # Strip out some stuff from the href that causes errors
    href = event['value']['data']['href'].gsub(/\[|\]/, '__').split('#').first
    path = URI(href).path

    # This is so we can show page views for single
    # page apps in the slider and sidebar as they
    # won't trigger a full snapshot
    data = event['value']
    data['data']['href'] = path
    data['type'] = Event::PAGE_VIEW
    @events.push(data)

    # Create the page view that we use for analytics
    @pageviews.push('path' => path, 'timestamp' => event['value']['timestamp'])
  end

  def handle_event(event)
    data = event['value']

    @events.push(data)
    @clicks.push(data) if Event.click?(data)
    @scrolls.push(data) if Event.scroll?(data)
    @cursors.push(data) if Event.cursor?(data)
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

  def handle_error(event)
    data = event['value']
    # This comes through as Event::CUSTOM as the script is not
    # aware of the extra codes but we should store it as Event::Error
    data['type'] = Event::ERROR
    @events.push(data)
    @errors.push(data)
  end

  def handle_custom(event)
    data = event['value']
    # This comes through as Event::CUSTOM as the script is not
    # aware of the extra codes but we should store it as Event::CustomTrack
    data['type'] = Event::CUSTOM_TRACK
    @events.push(data)
    @custom_tracking.push(data)
  end

  def parse_event_and_ignore_errors(event)
    zstream = Zlib::Inflate.new

    str = Base64.decode64(event)
    str = zstream.inflate(str)
    zstream.finish
    zstream.close

    JSON.parse!(str)
  rescue JSON::ParserError => e
    # There have been cases where individual events are not valid
    # json, but it seems to be due to some weird encoding on the
    # client. I think it's best to ignore these and try and
    # continue as the rest of the data is still useful
    Rails.logger.warn "Failed to parse JSON #{e}"
    nil
  rescue Zlib::DataError => e
    Rails.logger.warn "Failed to deflate zlib #{e}"
    nil
  end

  def ignore_event?(event)
    return true if event['data'].nil?
    # We don't want our own errors appearing in peoples feeds as it
    # makes us look bad
    return true if event['data']['stack']&.include?('cdn.squeaky.ai')

    false
  end

  # Given two timestamps, how much of that time
  # was actually active
  def activity_duration_between_timestamps(from_timestamp, to_timestamp)
    timestamp_offset = events.first['timestamp']
    total_duration = to_timestamp - from_timestamp

    inactivity.each do |(from_inactive, to_inactive)|
      # Only take inactivity that is between the two timestamps
      next unless [from_inactive, to_inactive].all? do |t|
        t.between?(from_timestamp - timestamp_offset, to_timestamp - timestamp_offset)
      end

      total_duration -= to_inactive - from_inactive
    end

    total_duration
  end

  def page_views # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
    page_views = []

    pageviews.each do |page|
      prev = page_views.last
      path = page['path']
      timestamp = page['timestamp']

      next if prev && prev[:url] == path

      prev[:exited_at] = timestamp if prev

      page_views.push(
        url: path,
        entered_at: timestamp,
        exited_at: timestamp,
        bounced_on: false,
        exited_on: false
      )
    end

    return [] unless page_views.any?

    page_views.last[:exited_at] = disconnected_at

    page_views.each do |pv|
      pv[:duration] = pv[:exited_at] - pv[:entered_at]
      pv[:activity_duration] = activity_duration_between_timestamps(pv[:entered_at], pv[:exited_at])
    end

    # Mark the page as being bounced on if there was
    # only a single page view
    page_views.first[:bounced_on] = true if page_views.size == 1
    # The last page was always the page that they exited on
    page_views.last[:exited_on] = true

    page_views
  end
end
