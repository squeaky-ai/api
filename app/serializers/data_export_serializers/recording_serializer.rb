# frozen_string_literal: true

module DataExportSerializers
  class RecordingSerializer
    def initialize(recording)
      @recording = recording
    end

    def serialize # rubocop:disable Metrics/AbcSize
      {
        recording_id: recording.id,
        visitor_id: recording.visitor.visitor_id,
        session_id: recording.session_id,
        status: recording.viewed ? 'Viewed' : 'New',
        referrer: recording.referrer,
        start_page: recording.start_page,
        exit_page: recording.exit_page,
        viewport_x: recording.viewport_x,
        viewport_y: recording.viewport_y,
        device_x: recording.device_x,
        device_y: recording.device_y,
        country_code: recording.country_code,
        country_name: recording.country_name,
        connected_at: recording.connected_at.iso8601,
        disconnected_at: recording.disconnected_at.iso8601,
        browser: recording.browser,
        language: recording.language,
        duration: recording.duration,
        page_views: recording.page_views.join('|'),
        page_count: recording.page_count,
        timezone: recording.timezone,
        nps_score: recording.nps&.score,
        sentiment_store: recording.sentiment&.score,
        activity_duration: recording.activity_duration,
        utm_term: recording.utm_term,
        utm_source: recording.utm_source,
        utm_medium: recording.utm_medium,
        utm_content: recording.utm_content,
        utm_campaign: recording.utm_campaign
      }
    end

    private

    attr_reader :recording
  end
end
