# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClickHouse::Recording, type: :model do
  describe '.create_from_session' do
    let(:site) { create(:site) }
    let(:recording) { create(:recording, site:) }

    subject { described_class.create_from_session(recording, {}) }

    it 'creates the recording in ClickHouse' do
      subject

      results = Sql::ClickHouse.select_one("
        SELECT
          recording_id,
          session_id,
          visitor_id,
          site_id,
          locale,
          device_x,
          browser,
          device_type,
          device_y,
          referrer,
          useragent,
          timezone,
          country_code,
          viewport_x,
          viewport_y,
          connected_at,
          disconnected_at,
          utm_source,
          utm_medium,
          utm_campaign,
          utm_content,
          utm_term,
          gad,
          gclid,
          activity_duration,
          inactivity,
          active_events_count,
          rage_clicked
        FROM recordings
        WHERE site_id = #{site.id} AND recording_id = #{recording.id}
      ")

      expect(results).to eq(
        'activity_duration' => 0,
        'browser' => recording.browser,
        'connected_at' => recording[:connected_at],
        'country_code' => recording.country_code,
        'device_type' => recording.device_type,
        'device_x' => recording.device_x,
        'device_y' => recording.device_y,
        'disconnected_at' => recording[:disconnected_at],
        'inactivity' => recording.inactivity.to_json,
        'locale' => recording.locale,
        'recording_id' => recording.id,
        'referrer' => recording.referrer,
        'session_id' => recording.session_id,
        'site_id' => recording.site_id,
        'timezone' => recording.timezone,
        'useragent' => recording.useragent,
        'utm_campaign' => recording.utm_campaign,
        'utm_content' => recording.utm_content,
        'utm_medium' => recording.utm_medium,
        'utm_source' => recording.utm_source,
        'utm_term' => recording.utm_term,
        'gad' => recording.gad.to_s,
        'gclid' => recording.gclid.to_s,
        'viewport_x' => recording.viewport_x,
        'viewport_y' => recording.viewport_y,
        'visitor_id' => recording.visitor_id,
        'active_events_count' => recording.active_events_count,
        'rage_clicked' => recording.rage_clicked
      )
    end
  end
end
