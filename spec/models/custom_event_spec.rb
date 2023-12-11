# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomEvent, type: :model do
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

    it 'inserts all the custom events' do
      subject

      results = CustomEvent
        .select('
          site_id,
          recording_id,
          name,
          data,
          url,
          viewport_x,
          viewport_y,
          device_x,
          device_y,
          source,
          visitor_id
        ')
        .where(site_id: site.id, recording_id: recording.id)
        .as_json

      expect(results).to match_array([
        {
          'id' => anything,
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
        data: { foo: 'bar' },
        site_id: site.id,
        visitor_id: visitor.id
      }
    end

    subject { described_class.create_from_api(event) }

    it 'inserts the custom event' do
      subject

      results = CustomEvent
        .select('
          site_id,
          recording_id,
          name,
          data,
          url,
          viewport_x,
          viewport_y,
          device_x,
          device_y,
          source,
          visitor_id
        ')
        .where(site_id: site.id)
        .as_json

      expect(results).to match_array([
        {
          'id' => anything,
          'site_id' => site.id,
          'recording_id' => nil,
          'data' => '{"foo":"bar"}',
          'device_x' => nil,
          'device_y' => nil,
          'name' => 'my-event',
          'source' => EventCapture::API,
          'visitor_id' => visitor.id,
          'url' => nil,
          'viewport_x' => nil,
          'viewport_y' => nil
        }
      ])
    end
  end
end
