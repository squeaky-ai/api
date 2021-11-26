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
    events_fixture = File.read("#{__dir__}/../../fixtures/events.json")
    allow(Redis.current).to receive(:lrange).and_return(JSON.parse(events_fixture))
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
end
