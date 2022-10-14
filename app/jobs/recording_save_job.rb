# frozen_string_literal: true

class RecordingSaveJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  before_perform do |job|
    args = job.arguments.first
    key = "job_lock::#{args['site_id']}::#{args['visitor_id']}::#{args['session_id']}"

    raise StandardError, "RecordingSaveJob lock hit for #{key}" if Cache.redis.get(key)

    Cache.redis.set(key, '1')
    Cache.redis.expire(key, 7200)
  end

  def perform(*args)
    message = args.first.symbolize_keys

    @session = Session.new(message)
    @site = Site.find_by(uuid: session.site_id)

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

  attr_reader :site, :session

  def store_session!
    ActiveRecord::Base.transaction do
      visitor = persist_visitor!
      recording = persist_recording!(visitor)

      persist_events!(recording)
      persist_pageviews!(recording)
      persist_sentiments!(recording)
      persist_nps!(recording)
      persist_clickhouse_data!(recording)
      persist_custom_event_names!
    end
  end

  def perform_post_save_actions!
    site.verify!
    session.clean_up!

    PlanService.alert_if_exceeded(site)
    RecordingMailerService.enqueue_if_first_recording(site)
  end

  def persist_visitor!
    visitor = find_or_create_visitor
    visitor.external_attributes = session.external_attributes
    visitor.save!
    visitor
  end

  def persist_recording!(visitor)
    Recording.create_from_session(session, visitor, site, recording_status)
  end

  def persist_events!(recording)
    session.events.each_slice(250).with_index do |slice, index|
      RecordingEventsService.create(
        recording:,
        body: slice.map { |s| { **s, id: SecureRandom.uuid } }.to_json,
        filename: "#{index}.json"
      )
    end
  end

  def persist_pageviews!(recording)
    pages = session.pages.map do |e|
      Page.new(
        url: e[:url],
        entered_at: e[:entered_at],
        exited_at: e[:exited_at],
        bounced_on: e[:bounced_on],
        exited_on: e[:exited_on],
        site_id: site.id
      )
    end

    recording.pages << pages
    recording.save
  end

  def persist_sentiments!(recording)
    session.sentiments.each do |e|
      Sentiment.create(
        score: e[:score],
        comment: e[:comment],
        recording:
      )
    end
  end

  def persist_nps!(recording)
    nps = session.nps

    return unless nps

    Nps.create(
      score: nps[:score],
      comment: nps[:comment],
      contact: nps[:contact],
      email: nps[:email],
      recording:
    )
  end

  def persist_clickhouse_data!(recording)
    [
      ClickHouse::Recording,
      ClickHouse::ClickEvent,
      ClickHouse::CustomEvent,
      ClickHouse::ErrorEvent,
      ClickHouse::PageEvent,
      ClickHouse::CursorEvent,
      ClickHouse::ScrollEvent
    ].each { |model| model.create_from_session(recording, session) }
  end

  def persist_custom_event_names!
    session.custom_tracking.each do |event|
      name = event['data']['name']

      event_capture = EventCapture.create(
        name:,
        rules: [{ matcher: 'equals', condition: 'or', value: name }],
        event_type: EventCapture::CUSTOM,
        site:,
        event_groups: []
      )

      logger.info "EventCapture with constrant #{name}:#{site.id} already exists" unless event_capture.valid?
    end
  end

  def valid?
    return false unless site

    return false if blacklisted_visitor?

    return false unless session.events?

    return false if session.duration.zero?

    return false unless session.recording?

    return false if session.exists?

    true
  end

  def recording_status
    # Recorings less than 3 seconds aren't worth viewing but are
    # good for analytics
    return Recording::DELETED if session.duration < 3000

    # Recordings without any user interaction are also not worth
    # watching, and is likely a bot
    return Recording::DELETED unless session.interaction?

    Recording::ACTIVE
  end

  def find_or_create_visitor # rubocop:disable Metrics/AbcSize
    if session.external_attributes['id']
      visitor = site
                .visitors
                .where("visitors.external_attributes->>'id' = ?", session.external_attributes['id'])
                .first

      return visitor if visitor
    end

    visitor = Visitor.create_or_find_by(visitor_id: session.visitor_id)
    visitor.update(site_id: site.id) unless visitor.site_id
    visitor
  end

  def blacklisted_visitor?
    email = session.external_attributes['email']

    return false unless email

    site.domain_blacklist.each do |blacklist|
      return true if blacklist['type'] == 'domain' && email.end_with?(blacklist['value'])
      return true if blacklist['type'] == 'email' && email == blacklist['value']
    end

    false
  end
end
