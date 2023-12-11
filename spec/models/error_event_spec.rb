# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorEvent, type: :model do
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

    it 'inserts all the errors' do
      subject

      results = ErrorEvent
        .select('
          site_id,
          recording_id,
          visitor_id,
          filename,
          message,
          url,
          viewport_x,
          viewport_y,
          device_x,
          device_y,
          stack,
          line_number,
          col_number
        ')
        .where(site_id: site.id, recording_id: recording.id)
        .as_json

      expect(results).to match_array([
        {
          'id' => anything,
          'site_id' => site.id,
          'recording_id' => recording.id,
          'visitor_id' => recording.visitor.id,
          'device_x' => 1920,
          'device_y' => 1080,
          'filename' => 'http://localhost:8081/examples/static/#',
          'message' => 'Error: Oh no',
          'url' => '/examples/static/',
          'viewport_x' => 1920,
          'viewport_y' => 1080,
          'stack' => 'onclick@http://localhost:8081/examples/static/#:74:16',
          'line_number' => 74,
          'col_number' => 25
        }
      ])
    end
  end
end
