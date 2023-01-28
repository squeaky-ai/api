# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClickHouse::CustomEvent, type: :model do
  describe '.create_from_session' do
    let(:message) do
      {
        site_id: SecureRandom.uuid,
        visitor_id: SecureRandom.uuid,
        session_id: SecureRandom.uuid
      }
    end

    let(:site) { create(:site) }
    let(:recording) { create(:recording, site:) }
    let(:session) { Session.new(message) }
    
    before do
      events_fixture = require_fixture('events.json', compress: true)
      allow(Cache.redis).to receive(:lrange).and_return(events_fixture)
    end

    subject { described_class.create_from_session(recording, session) }

    it 'inserts all the custom events in ClickHouse' do
      subject

      results = Sql::ClickHouse.select_all("
        SELECT site_id, recording_id, name, data, url, viewport_x, viewport_y, device_x, device_y, source, visitor_id
        FROM custom_events
        WHERE site_id = #{site.id} AND recording_id = #{recording.id}
      ")

      expect(results).to match_array([
        {
          'site_id' => site.id,
          'recording_id' => recording.id, 
          'data' => '{"foo":"bar"}', 
          'device_x' => 1920, 
          'device_y' => 1080, 
          'name' => 'my-event', 
          'source' => EventCapture::WEB,
          'visitor_id' => recording.visitor.id,
          'url' => '/examples/static/', 
          'viewport_x' => 1920, 
          'viewport_y' => 1080
        }
      ])
    end
  end

  describe '.create_from_api' do
    let(:site) { create(:site) }
    let(:visitor) { create(:visitor, site_id: site.id) }
    
    let(:event) do
      {
        name: 'my-event',
        data: { foo: 'bar' }
      }
    end

    subject { described_class.create_from_api(site, visitor, event) }

    it 'inserts the custom event in ClickHouse' do
      subject

      results = Sql::ClickHouse.select_all("
        SELECT site_id, recording_id, name, data, url, viewport_x, viewport_y, device_x, device_y, source, visitor_id
        FROM custom_events
        WHERE site_id = #{site.id} AND visitor_id = #{visitor.id}
      ")

      expect(results).to match_array([
        {
          'site_id' => site.id,
          'recording_id' => 0, 
          'data' => '{"foo":"bar"}', 
          'device_x' => 0, 
          'device_y' => 0, 
          'name' => 'my-event', 
          'source' => EventCapture::API,
          'visitor_id' => visitor.id,
          'url' => '', 
          'viewport_x' => 0, 
          'viewport_y' => 0
        }
      ])
    end
  end
end
