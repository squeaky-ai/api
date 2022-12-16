# frozen_string_literal: true

class RecordingSerializer
  def initialize(recording)
    @recording = recording
  end

  def serialize # rubocop:disable Metrics/AbcSize
    {
      id: recording.id,
      site_id: recording.site_id,
      session_id: recording.session_id,
      viewed: recording.viewed,
      bookmarked: recording.bookmarked,
      language: recording.language,
      duration: recording.duration,
      page_views: recording.page_views,
      page_count: recording.page_count,
      start_page: recording.start_page,
      exit_page: recording.exit_page,
      referrer: recording.referrer,
      timezone: recording.timezone,
      country_code: recording.country_code,
      country_name: recording.country_name,
      device: recording.device,
      connected_at: recording.connected_at.iso8601,
      disconnected_at: recording.disconnected_at.iso8601,
      tag_ids: recording.tags.map(&:id),
      note_ids: recording.notes.map(&:id),
      nps_score: recording.nps&.score,
      sentiment_store: recording.sentiment&.score,
      activity_duration: recording.activity_duration,
      inactivity: recording.inactivity,
      utm_term: recording.utm_term,
      utm_source: recording.utm_source,
      utm_medium: recording.utm_medium,
      utm_content: recording.utm_content,
      utm_campaign: recording.utm_campaign,
      visitor: {
        id: recording.visitor.id,
        visitor_id: recording.visitor.visitor_id
      }
    }
  end

  private

  attr_reader :recording
end
