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
        language
        duration
        duration_string
        pages
        page_count
        start_page
        exit_page
        device_type
        browser
        browser_string
        viewport_x
        viewport_y
        date_string
      ]
    end
  end

  describe '#user_agent' do
    let(:subject) do
      fixture = recording_fixture.dup
      fixture[:useragent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 \
      (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
      described_class.new(fixture)
    end

    it 'returns an instance of UserAgent' do
      expect(subject.user_agent).to be_instance_of(UserAgent::Browsers::Webkit)
    end
  end

  describe '#pages' do
    let(:subject) do
      fixture = recording_fixture.dup
      fixture[:page_views] = Set.new(['/', '/pricing', '/pricing/test'])
      described_class.new(fixture)
    end

    it 'returns the pages' do
      expect(subject.pages).to eq(['/', '/pricing', '/pricing/test'])
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
      fixture[:connected_at] = (Time.now.to_f * 1000).to_i - 5
      fixture[:disconnected_at] = (Time.now.to_f * 1000).to_i
      described_class.new(fixture)
    end

    it 'returns the difference between the connected and disconnected dates' do
      expect(subject.duration).to eq 5
    end
  end

  describe '#duration_string' do
    let(:subject) do
      fixture = recording_fixture.dup
      fixture[:connected_at] = (Time.now.to_f * 1000).to_i - 5
      fixture[:disconnected_at] = (Time.now.to_f * 1000).to_i
      described_class.new(fixture)
    end

    it 'returns the difference in a formatted string' do
      expect(subject.duration_string).to eq '00:05'
    end
  end

  describe '#event_key' do
    let(:subject) { described_class.new(recording_fixture) }

    it 'returns the event key' do
      expect(subject.event_key).to eq "#{subject.site_id}_#{subject.session_id}"
    end
  end

  describe '#device_type' do
    context 'when the device is a computer' do
      let(:subject) do
        fixture = recording_fixture.dup
        fixture[:useragent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 \
        (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
        described_class.new(fixture)
      end

      it 'returns the device type' do
        expect(subject.device_type).to eq 'Computer'
      end
    end

    context 'when the devise is a mobile' do
      let(:subject) do
        fixture = recording_fixture.dup
        fixture[:useragent] = 'Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 \
        (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1'
        described_class.new(fixture)
      end

      it 'returns the device type' do
        expect(subject.device_type).to eq 'Mobile'
      end
    end
  end

  describe '#browser' do
    let(:subject) do
      fixture = recording_fixture.dup
      fixture[:useragent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 \
      (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
      described_class.new(fixture)
    end

    it 'returns the browser' do
      expect(subject.browser).to eq 'Safari'
    end
  end

  describe '#browser_string' do
    let(:subject) do
      fixture = recording_fixture.dup
      fixture[:useragent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 \
      (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
      described_class.new(fixture)
    end

    it 'returns the browser string' do
      expect(subject.browser_string).to eq 'Safari Version 14.1.1'
    end
  end

  describe '#language' do
    context 'when the locale is known' do
      let(:subject) do
        fixture = recording_fixture.dup
        fixture['locale'] = 'en-gb'
        described_class.new(fixture)
      end

      it 'returns the language' do
        expect(subject.language).to eq 'English (GB)'
      end
    end

    context 'when the locale is not known' do
      let(:subject) do
        fixture = recording_fixture.dup
        fixture['locale'] = 'za-3f'
        described_class.new(fixture)
      end

      it 'returns the fallback' do
        expect(subject.language).to eq 'Unknown'
      end
    end
  end

  describe '#date_string' do
    let(:subject) do
      fixture = recording_fixture.dup
      fixture[:connected_at] = 1_624_872_484_361
      fixture[:disconnected_at] = 1_624_872_484_366
      described_class.new(fixture)
    end

    it 'returns a nicely formatted date' do
      expect(subject.date_string).to eq '28th June 2021'
    end
  end
end
