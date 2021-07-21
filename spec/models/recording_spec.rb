# frozen_string_literal: true

require 'date'
require 'rails_helper'
require 'securerandom'

RSpec.describe Recording, type: :model do
  let(:recording_fixture) do
    {
      site_id: SecureRandom.uuid,
      session_id: Faker::Lorem.word,
      viewer_id: Faker::Lorem.word
    }
  end

  describe '#user_agent' do
    subject do
      fixture = recording_fixture.dup
      fixture[:useragent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
      described_class.new(fixture).user_agent
    end

    it 'returns an instance of UserAgent' do
      expect(subject).to be_instance_of(UserAgent::Browsers::Webkit)
    end
  end

  describe '#page_count' do
    let (:instance) { described_class.new(recording_fixture) }
    
    subject do
      fixture = recording_fixture.dup
      fixture[:page_views] = ['/', '/contact', '/test']
      described_class.new(fixture).page_count
    end

    it 'returns the number of pages visited' do
      expect(subject).to eq 3
    end
  end

  describe '#duration' do
    subject do
      fixture = recording_fixture.dup
      fixture[:connected_at] = 1625389200000
      fixture[:disconnected_at] = 1625389205000
      described_class.new(fixture).duration
    end

    it 'returns the difference between the connected and disconnected dates' do
      expect(subject).to eq 5
    end
  end

  describe '#duration_string' do
    subject do
      fixture = recording_fixture.dup
      fixture[:connected_at] = 1625389200000
      fixture[:disconnected_at] = 1625389205000
      described_class.new(fixture).duration_string
    end

    it 'returns the difference in a formatted string' do
      expect(subject).to eq '00:05'
    end
  end

  describe '#locale' do
    context 'when there is a locale in the events' do
      subject do
        fixture = recording_fixture.dup
        fixture[:locale] = 'en-GB'
        described_class.new(fixture).locale
      end

      it 'returns the locale' do
        expect(subject).to eq 'en-GB'
      end
    end

    context 'when there is no locale' do
      subject do
        described_class.new(recording_fixture).locale
      end

      it 'returns nil' do
        expect(subject).to be nil
      end
    end
  end

  describe '#device_type' do
    context 'when the device is a computer' do
      subject do
        fixture = recording_fixture.dup
        fixture[:useragent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
        described_class.new(fixture).device_type
      end

      it 'returns the device type' do
        expect(subject).to eq 'Computer'
      end
    end

    context 'when the devise is a mobile' do
      subject do
        fixture = recording_fixture.dup
        fixture[:useragent] = 'Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1'
        described_class.new(fixture).device_type
      end

      it 'returns the device type' do
        expect(subject).to eq 'Mobile'
      end
    end
  end

  describe '#browser' do
    subject do
      fixture = recording_fixture.dup
      fixture[:useragent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
      described_class.new(fixture).browser
    end

    it 'returns the browser' do
      expect(subject).to eq 'Safari'
    end
  end

  describe '#browser_string' do
    subject do
      fixture = recording_fixture.dup
      fixture[:useragent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
      described_class.new(fixture).browser_string
    end

    it 'returns the browser string' do
      expect(subject).to eq 'Safari Version 14.1.1'
    end
  end

  describe '#language' do
    context 'when the locale is known' do
      subject do
        fixture = recording_fixture.dup
        fixture[:locale] = 'en-GB'
        described_class.new(fixture).language
      end

      it 'returns the language' do
        expect(subject).to eq 'English (GB)'
      end
    end

    context 'when the locale is not known' do
      subject do
        described_class.new(recording_fixture).language
      end

      it 'returns the fallback' do
        expect(subject).to eq 'Unknown'
      end
    end
  end

  describe '#date_string' do
    subject do
      fixture = recording_fixture.dup
      fixture[:connected_at] = 1625389200000
      described_class.new(fixture).date_string
    end

    it 'returns a nicely formatted date' do
      expect(subject).to eq '4th July 2021'
    end
  end
end
