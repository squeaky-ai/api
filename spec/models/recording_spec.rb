# frozen_string_literal: true

require 'date'
require 'rails_helper'
require 'securerandom'

RSpec.describe Recording, type: :model do
  let(:recording_fixture) do
    {
      site_id: SecureRandom.uuid,
      session_id: Faker::Lorem.word,
      viewer_id: Faker::Lorem.word,
      locale: 'en-gb',
      useragent: Faker::Internet.user_agent
    }
  end

  describe '#to_h' do
    subject { described_class.new(recording_fixture) }

    it 'contains the expected key' do
      expect(subject.to_h.keys).to eq %i[
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
        tags
        notes
        timestamp
        events
      ]
    end
  end

  describe '#user_agent' do
    subject do
      recording = described_class.new(recording_fixture)

      data = { href: 'http://localhost/', width: 0, height: 0, useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15' }
      recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)

      recording
    end

    it 'returns an instance of UserAgent' do
      expect(subject.user_agent).to be_instance_of(UserAgent::Browsers::Webkit)
    end
  end

  describe '#page_count' do
    let (:instance) { described_class.new(recording_fixture) }
    
    subject do
      recording = described_class.new(recording_fixture)

      ['/', '/contact', '/test'].each do |path|
        data = { href: "http://localhost#{path}", width: 0, height: 0 }
        recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)
      end

      recording
    end

    it 'returns the number of pages visited' do
      expect(subject.page_count).to eq 3
    end
  end

  describe '#duration' do
    subject do
      recording = described_class.new(recording_fixture)

      data = { href: 'http://localhost/', width: 0, height: 0 }
      recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)
      recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389205000)

      recording
    end

    it 'returns the difference between the connected and disconnected dates' do
      expect(subject.duration).to eq 5
    end
  end

  describe '#duration_string' do
    subject do
      recording = described_class.new(recording_fixture)

      data = { href: 'http://localhost/', width: 0, height: 0 }
      recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)
      recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389205000)

      recording
    end

    it 'returns the difference in a formatted string' do
      expect(subject.duration_string).to eq '00:05'
    end
  end

  describe '#locale' do
    context 'when there is a locale in the events' do
      subject do
        recording = described_class.new(recording_fixture)
  
        data = { href: 'http://localhost/', width: 0, height: 0, locale: 'en-gb' }
        recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)
  
        recording
      end

      it 'returns the locale' do
        expect(subject.locale).to eq 'en-gb'
      end
    end

    context 'when there is no locale in the events' do
      subject do
        recording = described_class.new(recording_fixture)
  
        data = { href: 'http://localhost/', width: 0, height: 0 }
        recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)
  
        recording
      end

      it 'returns nil' do
        expect(subject.locale).to be nil
      end
    end
  end

  describe '#device_type' do
    context 'when the device is a computer' do
      subject do
        recording = described_class.new(recording_fixture)
  
        data = { href: 'http://localhost/', width: 0, height: 0, useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15' }
        recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)
  
        recording
      end

      it 'returns the device type' do
        expect(subject.device_type).to eq 'Computer'
      end
    end

    context 'when the devise is a mobile' do
      subject do
        recording = described_class.new(recording_fixture)
  
        data = { href: 'http://localhost/', width: 0, height: 0, useragent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1' }
        recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)
  
        recording
      end

      it 'returns the device type' do
        expect(subject.device_type).to eq 'Mobile'
      end
    end
  end

  describe '#browser' do
    subject do
      recording = described_class.new(recording_fixture)

      data = { href: 'http://localhost/', width: 0, height: 0, useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15' }
      recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)

      recording
    end

    it 'returns the browser' do
      expect(subject.browser).to eq 'Safari'
    end
  end

  describe '#browser_string' do
    subject do
      recording = described_class.new(recording_fixture)

      data = { href: 'http://localhost/', width: 0, height: 0, useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15' }
      recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)

      recording
    end

    it 'returns the browser string' do
      expect(subject.browser_string).to eq 'Safari Version 14.1.1'
    end
  end

  describe '#language' do
    context 'when the locale is known' do
      subject do
        recording = described_class.new(recording_fixture)
  
        data = { href: 'http://localhost/', width: 0, height: 0, locale: 'en-gb' }
        recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)
  
        recording
      end

      it 'returns the language' do
        expect(subject.language).to eq 'English (GB)'
      end
    end

    context 'when the locale is not known' do
      subject do
        recording = described_class.new(recording_fixture)
  
        data = { href: 'http://localhost/', width: 0, height: 0, locale: 'za-4f' }
        recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)
  
        recording
      end

      it 'returns the fallback' do
        expect(subject.language).to eq 'Unknown'
      end
    end
  end

  describe '#date_string' do
    subject do
      recording = described_class.new(recording_fixture)

      data = { href: 'http://localhost/', width: 0, height: 0 }
      recording.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)

      recording
    end

    it 'returns a nicely formatted date' do
      expect(subject.date_string).to eq '4th July 2021'
    end
  end
end
