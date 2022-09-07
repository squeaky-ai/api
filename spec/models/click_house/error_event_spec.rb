# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClickHouse::ErrorEvent, type: :model do
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
      events_fixture = require_fixture('events.json')
      allow(Cache.redis).to receive(:lrange).and_return(events_fixture)
    end

    subject { described_class.create_from_session(recording, session) }

    it 'inserts all the errors in ClickHouse' do  
      subject

      results = ClickHouse.connection.select_all("
        SELECT site_id, recording_id, filename, message, url, viewport_x, viewport_y, device_x, device_y
        FROM error_events
        WHERE site_id = #{site.id}
      ")

      expect(results).to match_array([
        {
          'site_id' => site.id, 
          'recording_id' => recording.id,
          'device_x' => 1920,
          'device_y' => 1080,
          'filename' => 'http://localhost:8081/examples/static/#',
          'message' => 'Error: Oh no',
          'url' => '/examples/static/',
          'viewport_x' => 1920, 
          'viewport_y' => 1080
        }
      ])
    end
  end
end
