# frozen_string_literal: true

class RecordingSaveJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*args)
    message = args.first.symbolize_keys

    @session = Session.new(message)
    @site = Site.find_by!(uuid: @session.site_id)

    return unless valid?

    store_session!
    perform_post_save_actions!

    logger.info 'Recording saved'
  end

  # It crashes for some reason without this
  def jid=(*args)
    args
  end

  private

  def store_session!
    ActiveRecord::Base.transaction do
      visitor = persist_visitor!
      recording = persist_recording!(visitor)

      persist_events!(recording)
      persist_pageviews!(recording)
      persist_sentiments!(recording)
      persist_nps!(recording)
      persist_clicks!(recording)
    end
  end

  def perform_post_save_actions!
    @site.verify!
    @session.clean_up!

    PlanService.alert_if_exceeded(@site)
  end

  def persist_visitor!
    visitor = find_or_create_visitor
    visitor.external_attributes = @session.external_attributes
    visitor.save!
    visitor
  end

  def persist_recording!(visitor)
    recording = @site.recordings.find_or_create_by(session_id: @session.session_id)

    if recording.new_record?
      recording.visitor_id = visitor.id
      recording.status = recording_status
      recording.locale = @session.locale
      recording.device_x = @session.device_x
      recording.browser = @session.browser
      recording.device_type = @session.device_type
      recording.device_y = @session.device_y
      recording.referrer = @session.referrer
      recording.useragent = @session.useragent
      recording.timezone = @session.timezone
      recording.country_code = @session.country_code
      recording.viewport_x = @session.viewport_x
      recording.viewport_y = @session.viewport_y
      recording.connected_at = @session.connected_at
      recording.utm_source = @session.utm_source
      recording.utm_medium = @session.utm_medium
      recording.utm_campaign = @session.utm_campaign
      recording.utm_content = @session.utm_content
      recording.utm_term = @session.utm_term
    end

    recording.disconnected_at = @session.disconnected_at

    recording.save!
    recording
  end

  def persist_events!(recording)
    now = Time.now
    # Batch insert all of the events. PG has a limit of
    # 65535 placeholders and some users spend bloody ages on
    # the site, so it's best to chunk all of these up so they
    # don't hit the limit
    @session.events.each_slice(100) do |slice|
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
    page_views = []

    @session.pageviews.each do |page|
      prev = page_views.last
      path = page['path']
      timestamp = page['timestamp']

      next if prev && prev[:url] == path

      prev[:exited_at] = timestamp if prev

      page_views.push(Page.new(url: path, entered_at: timestamp, exited_at: timestamp))
    end

    return unless page_views.any?

    page_views.last.exited_at = recording[:disconnected_at]

    recording.pages << page_views
    recording.save
  end

  def persist_sentiments!(recording)
    @session.sentiments.each do |e|
      Sentiment.create(
        score: e[:score],
        comment: e[:comment],
        recording:
      )
    end
  end

  def persist_nps!(recording)
    nps = @session.nps

    return unless nps

    Nps.create(
      score: nps[:score],
      comment: nps[:comment],
      contact: nps[:contact],
      email: nps[:email],
      recording:
    )
  end

  def persist_clicks!(recording)
    items = []

    @session.events.each do |event|
      next unless event['type'] == 3 &&
                  event['data']['source'] == 2 &&
                  event['data']['type'] == 2

      items.push(
        selector: event['data']['selector'] || 'html > body',
        coordinates_x: event['data']['x'] || 0,
        coordinates_y: event['data']['y'] || 0,
        clicked_at: event['timestamp'],
        page_url: event['data']['href'] || '/',
        viewport_x: recording.viewport_x,
        viewport_y: recording.viewport_y,
        site_id: recording.site_id
      )
    end

    Click.insert_all!(items) unless items.empty?
  end

  def valid?
    return false if blacklisted_visitor?

    return false unless @session.events?

    return false if @session.duration.zero?

    return false unless @session.recording?

    true
  end

  def recording_status
    # Users can unlock these recordings if they upgrade their
    # plan or pay for their bill
    return Recording::LOCKED if @site.plan.exceeded? || @site.plan.invalid?

    # Recorings less than 3 seconds aren't worth viewing but are
    # good for analytics
    return Recording::DELETED if @session.duration < 3000

    # Recordings without any user interaction are also not worth
    # watching, and is likely a bot
    return Recording::DELETED unless @session.interaction?

    Recording::ACTIVE
  end

  def find_or_create_visitor
    if @session.external_attributes['id']
      visitor = @site
                .visitors
                .where("visitors.external_attributes->>'id' = ?", @session.external_attributes['id'])
                .first

      return visitor if visitor
    end

    Visitor.create_or_find_by(visitor_id: @session.visitor_id)
  end

  def blacklisted_visitor?
    email = @session.external_attributes['email']

    return false unless email

    @site.domain_blacklist.each do |blacklist|
      return true if blacklist['type'] == 'domain' && email.end_with?(blacklist['value'])
      return true if blacklist['type'] == 'email' && email == blacklist['value']
    end

    false
  end
end
