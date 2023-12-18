# frozen_string_literal: true

class RecordingSaveJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: 0

  def perform(*args)
    message = args.first.symbolize_keys

    return if lock_hit?(message)

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

  attr_reader :site, :session, :recording, :visitor

  def lock_hit?(message)
    key = "job_lock::#{message[:site_id]}::#{message[:visitor_id]}::#{message[:session_id]}"

    return true if Cache.redis.get(key)

    Cache.redis.set(key, '1')
    Cache.redis.expire(key, 7200)

    false
  end

  def store_session!
    ActiveRecord::Base.transaction do
      # This HAS to go first
      persist_visitor!
      # This HAS to go second
      persist_recording!

      # The order of these is not important
      persist_pageviews!
      persist_sentiments!
      persist_nps!
    end

    persist_events!
    persist_clickhouse_data!
    persist_custom_event_names!
  end

  def perform_post_save_actions!
    site.verify!
    session.clean_up!

    PlanService.alert_if_exceeded(site)
    PlanService.alert_if_nearing_limit(site)
    RecordingMailerService.enqueue_if_first_recording(site)
  end

  def persist_visitor!
    @visitor = find_or_create_visitor
    @visitor.external_attributes = session.external_attributes
    @visitor.save!
  end

  def persist_recording!
    @recording = Recording.create_from_session!(session, visitor, site, recording_status)
  end

  def persist_events!
    return if recording.analytics_only?

    session.events.each_slice(250).with_index do |slice, index|
      RecordingEventsService.create(
        recording:,
        body: slice.map { |s| { **s, id: SecureRandom.uuid } }.to_json,
        filename: "#{index}.json"
      )
    end
  end

  def persist_pageviews!
    pages = session.pages.map do |e|
      Page.new(
        url: e[:url],
        entered_at: e[:entered_at],
        exited_at: e[:exited_at],
        bounced_on: e[:bounced_on],
        exited_on: e[:exited_on],
        duration: e[:duration],
        activity_duration: e[:activity_duration],
        site_id: site.id
      )
    end

    recording.pages << pages
    recording.save!
  end

  def persist_sentiments!
    session.sentiments.each do |e|
      Sentiment.create!(
        score: e[:score],
        comment: e[:comment],
        recording:
      )
    end
  end

  def persist_nps!
    nps = session.nps

    return unless nps

    Nps.create!(
      score: nps[:score],
      comment: nps[:comment],
      contact: nps[:contact],
      email: nps[:email],
      recording:
    )
  end

  def persist_clickhouse_data!
    [
      ClickHouse::Recording,
      ClickHouse::ClickEvent,
      ClickHouse::CustomEvent,
      ClickHouse::ErrorEvent,
      ClickHouse::PageEvent,
      ClickHouse::CursorEvent,
      ClickHouse::ScrollEvent,
      # Remove above once migrated
      ClickEvent,
      CustomEvent,
      ErrorEvent,
      PageEvent,
      CursorEvent,
      ScrollEvent
    ].each { |model| model.create_from_session(recording, session) }
  end

  def persist_custom_event_names!
    # No point in trying to create 10 of the same one
    event_names = session.custom_tracking.map { |e| e['data']['name'] }.uniq
    EventCapture.create_names_for_site!(site, event_names, EventCapture::WEB)
  end

  def valid? # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
    unless site
      Rails.logger.info 'Recording did not save because there was no site'
      return false
    end

    if blacklisted_visitor?
      Rails.logger.info 'Recording did not save because the visitor was blacklisted'
      return false
    end

    unless session.events?
      Rails.logger.info 'Recording did not save because there were not events'
      return false
    end

    if session.duration.zero?
      Rails.logger.info 'Recording did not save because the duration was 0'
      return false
    end

    unless session.recording?
      Rails.logger.info 'Recording did not save because the recording check failed'
      return false
    end

    if session.exists?
      Rails.logger.info 'Recording did not save because the session exists'
      return false
    end

    if session.pages.empty?
      Rails.logger.info 'Recording did not save because there were no pages'
      return false
    end

    true
  end

  def recording_status
    # Recorings less than 3 seconds aren't worth viewing but are
    # good for analytics
    return Recording::ANALYTICS_ONLY if session.duration < 3000

    # Recordings without any user interaction are also not worth
    # watching, and is likely a bot
    return Recording::ANALYTICS_ONLY unless session.interaction?

    # They don't pay for recordings so set it as analytics only
    return Recording::ANALYTICS_ONLY unless site.plan.features_enabled.include?('recordings')

    Recording::ACTIVE
  end

  def find_or_create_visitor
    if session.external_attributes['id']
      visitor = Visitor.find_by_external_id(site.id, session.external_attributes['id'])
      return visitor if visitor
    end

    Visitor.create_or_find_by(visitor_id: session.visitor_id) do |v|
      v.source = Visitor::WEB
      v.site_id = site.id unless v.site_id
    end
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
