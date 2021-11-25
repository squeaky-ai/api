# frozen_string_literal: true

class RecordingSaveJob < ApplicationJob
  queue_as :default

  before_perform do |job|
    message = JSON.parse(job.arguments[0], symbolize_names: true)

    @session = Session.new(message)
    @site = Site.find_by!(uuid: @session.site_id)
  end

  def perform(*_args, **_kwargs)
    return unless valid?

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
    visitor = find_or_create_visitor
    visitor.external_attributes = @session.external_attributes
    visitor.save!
    visitor
  end

  def persist_recording!(visitor)
    recording = @site.recordings.find_or_create_by(session_id: @session.session_id)

    if recording.new_record?
      recording.visitor_id = visitor.id
      recording.deleted = soft_delete?
      recording.locale = @session.locale
      recording.device_x = @session.device_x
      recording.device_y = @session.device_y
      recording.referrer = @session.referrer
      recording.useragent = @session.useragent
      recording.viewport_x = @session.viewport_x
      recording.viewport_y = @session.viewport_y
      recording.connected_at = @session.connected_at
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
    now = Time.now
    page_views = []

    @session.pageviews.each do |page|
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

    Page.insert_all!(page_views) if page_views.size
  end

  def valid?
    return false if blacklisted_visitor?

    return false unless @session.events?

    return false if @session.duration.zero?

    return false if @site.recording_count_exceeded?

    true
  end

  def soft_delete?
    # Recorings less than 3 seconds aren't worth viewing but are
    # good for analytics
    return true if @session.duration < 3000

    # Recordings without any user interaction are also not worth
    # watching, and is likely a bot
    return true unless @session.interaction?

    false
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
