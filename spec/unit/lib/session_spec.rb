# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe Session do
  let(:message) do
    {
      site_id: SecureRandom.uuid,
      visitor_id: SecureRandom.uuid,
      session_id: SecureRandom.uuid
    }
  end

  before do
    events_fixture = require_fixture('events.json')
    allow(Cache.redis).to receive(:lrange).and_return(events_fixture)
  end

  let(:instance) { Session.new(message) }

  describe '#locale' do
    it 'returns the locale' do
      expect(instance.locale).to eq 'en-GB'
    end
  end

  describe '#useragent' do
    it 'returns the useragent' do
      expect(instance.useragent).to eq 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:95.0) Gecko/20100101 Firefox/95.0'
    end
  end

  describe '#viewport_x' do
    it 'returns the viewport_x' do
      expect(instance.viewport_x).to eq 1813
    end
  end

  describe '#viewport_y' do
    it 'returns the viewport_y' do
      expect(instance.viewport_y).to eq 1813
    end
  end

  describe '#device_x' do
    it 'returns the device_x' do
      expect(instance.device_x).to eq 3840
    end
  end

  describe '#device_y' do
    it 'returns the device_y' do
      expect(instance.device_y).to eq 1600
    end
  end

  describe '#referrer' do
    it 'returns the referrer' do
      expect(instance.referrer).to eq nil
    end
  end

  describe '#connected_at' do
    it 'returns the connected_at' do
      expect(instance.connected_at).to eq 1637177342265
    end
  end

  describe '#disconnected_at' do
    it 'returns the disconnected_at' do
      expect(instance.disconnected_at).to eq 1637177353431
    end
  end

  describe '#duration' do
    it 'returns the duration' do
      expect(instance.duration).to eq 11166
    end
  end

  describe '#timezone' do
    it 'returns the timezone' do
      expect(instance.timezone).to eq 'Europe/London'
    end
  end

  describe '#country_code' do
    it 'returns the country code' do
      expect(instance.country_code).to eq 'GB'
    end
  end

  describe '#events?' do
    it 'returns whether there are events' do
      expect(instance.events?).to eq true
    end
  end

  describe '#pageviews?' do
    it 'returns whether there are pageviews' do
      expect(instance.pageviews?).to eq true
    end
  end

  describe '#recording?' do
    it 'returns whether there are all the properties required for a recording' do
      expect(instance.recording?).to eq true
    end
  end

  describe '#interaction?' do
    it 'returns whether there was any user interaction' do
      expect(instance.interaction?).to eq true
    end
  end

  describe '#utm_source' do
    it 'returns the utm source' do
      expect(instance.utm_source).to eq 'google'
    end
  end

  describe '#utm_medium' do
    it 'returns the utm medium' do
      expect(instance.utm_medium).to eq 'organic'
    end
  end

  describe '#utm_campaign' do
    it 'returns the utm campaign' do
      expect(instance.utm_campaign).to eq 'my_campaign'
    end
  end

  describe '#utm_content' do
    it 'returns the utm content' do
      expect(instance.utm_content).to eq 'test'
    end
  end

  describe '#utm_term' do
    it 'returns the utm term' do
      expect(instance.utm_term).to eq 'analytics'
    end
  end

  context 'when the events include some bad json' do
    before do
      event_1 = { key: 'event', value: { timestamp: 1651157003244 } }.to_json
      event_2 = 'sdfdsf{}11@@@2'

      allow(Cache.redis).to receive(:lrange).and_return([event_1, event_2])
      allow(Rails.logger).to receive(:warn).and_call_original
    end

    it 'skips bad events' do
      expect(instance.events.size).to eq 1
    end

    it 'logs a warning' do
      instance
      expect(Rails.logger).to have_received(:warn).with('Failed to parse JSON 859: unexpected token at \'sdfdsf{}11@@@2\'')
    end
  end
end
