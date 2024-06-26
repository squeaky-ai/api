# frozen_string_literal: true

module ClickHouse
  class Recording < Base
    def self.create_from_session(recording, _session) # rubocop:disable Metrics/AbcSize
      insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          recording_id: recording.id,
          session_id: recording.session_id,
          visitor_id: recording.visitor_id,
          site_id: recording.site_id,
          locale: recording.locale,
          device_x: recording.device_x,
          browser: recording.browser,
          device_type: recording.device_type,
          device_y: recording.device_y,
          referrer: recording.referrer,
          useragent: recording.useragent,
          timezone: recording.timezone,
          country_code: recording.country_code,
          viewport_x: recording.viewport_x,
          viewport_y: recording.viewport_y,
          connected_at: recording[:connected_at],
          disconnected_at: recording[:disconnected_at],
          utm_source: recording.utm_source,
          utm_medium: recording.utm_medium,
          utm_campaign: recording.utm_campaign,
          utm_content: recording.utm_content,
          utm_term: recording.utm_term,
          gad: recording.gad,
          gclid: recording.gclid,
          activity_duration: recording.activity_duration,
          inactivity: recording.inactivity.to_json,
          active_events_count: recording.active_events_count,
          rage_clicked: recording.rage_clicked,
          u_turned: recording.u_turned,
          status: recording.status
        }
      end
    rescue ClickHouse::DbException => e
      Rails.logger.error "Failed to insert recording to clickhouse: #{e} - #{recording.to_json}"
      raise
    end

    def self.delete_from_recordings(recording_ids:)
      Sql::ClickHouse.execute("DELETE FROM #{table_name} WHERE recording_id IN (?)", [recording_ids])
    end
  end
end
