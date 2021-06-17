# frozen_string_literal: true

require 'date'
require 'rails_helper'
require 'securerandom'

RSpec.describe Recording, type: :model do
  let(:recording_fixture) do
    {
      site_id: SecureRandom.uuid,
      session_id: Faker::String.random(length: 8),
      viewer_id: Faker::String.random(length: 8),
      locale: 'en-gb',
      start_page: '/',
      exit_page: '/pricing',
      useragent: Faker::Internet.user_agent,
      viewport_x: 1920,
      viewport_y: 1080,
      active: false,
      page_views: Set.new,
      connected_at: DateTime.now.iso8601,
      disconnected_at: DateTime.now.iso8601
    }
  end

  describe '#serialize' do
    let(:subject) { described_class.new(recording_fixture) }

    it 'contains the expected key' do
      expect(subject.serialize.keys).to eq %i[
        id
        site_id
        viewer_id
        active
        locale
        duration
        page_count
        start_page
        exit_page
        useragent
        device_type
        browser
        viewport_x
        viewport_y
      ]
    end
  end

  describe '#page_count' do
    let(:subject) do
      fixture = recording_fixture.dup
      fixture[:page_views] = Set.new(['/', '/pricing', '/pricing/test'])
      described_class.new(fixture)
    end

    it 'returns the number of pages visited' do
      expect(subject.page_count).to eq 3
    end
  end

  describe '#duration' do
    let(:subject) do
      fixture = recording_fixture.dup
      fixture[:connected_at] = (DateTime.now - 5 / 86_400.0).iso8601
      fixture[:disconnected_at] = DateTime.now.iso8601
      described_class.new(fixture)
    end

    it 'returns the difference between the connected and disconnected dates' do
      expect(subject.duration).to eq 5
    end
  end

  describe '#event_key' do
    let(:subject) { described_class.new(recording_fixture) }

    it 'returns the event key' do
      expect(subject.event_key).to eq "#{subject.site_id}_#{subject.session_id}"
    end
  end

  describe '#device_type' do
    let(:subject) do
      fixture = recording_fixture.dup
      fixture[:useragent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) \
      Version/14.1.1 Safari/605.1.15'
      described_class.new(fixture)
    end

    it 'returns the device type' do
      expect(subject.device_type).to eq 'Mac'
    end
  end

  describe '#browser' do
    let(:subject) do
      fixture = recording_fixture.dup
      fixture[:useragent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) \
      Version/14.1.1 Safari/605.1.15'
      described_class.new(fixture)
    end

    it 'returns the browser' do
      expect(subject.browser).to eq 'Safari'
    end
  end
end
