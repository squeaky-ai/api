# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recording, type: :model do
  let(:recording_fixture) do
    {
      site_id: rand(10000),
      session_id: SecureRandom.base36,
      visitor_id: SecureRandom.base36
    }
  end

  describe '#user_agent' do
    subject do
      fixture = recording_fixture.dup
      fixture[:useragent] =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
      described_class.new(fixture).user_agent
    end

    it 'returns an instance of UserAgent' do
      expect(subject).to be_instance_of(UserAgent::Browsers::Webkit)
    end
  end

  describe '#page_count' do
    let(:instance) { described_class.new(recording_fixture) }

    subject do
      site = create(:site)
      recording = create(:recording, site:, page_urls: ['/', '/contact', '/test'])

      recording.reload.page_count
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
      expect(subject).to eq 5000
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

  describe '#device' do
    context 'when the device is a computer' do
      subject do
        fixture = recording_fixture.dup
        fixture[:device_type] = 'Computer'
        described_class.new(fixture).device
      end

      it 'returns the device type' do
        expect(subject[:device_type]).to eq 'Computer'
      end
    end

    context 'when the device is a mobile' do
      subject do
        fixture = recording_fixture.dup
        fixture[:device_type] = 'Mobile'
        described_class.new(fixture).device
      end

      it 'returns the device type' do
        expect(subject[:device_type]).to eq 'Mobile'
      end
    end

    context 'when the browser is set' do
      subject do
        fixture = recording_fixture.dup
        fixture[:useragent] =
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
        fixture[:browser] = 'Safari'
        described_class.new(fixture).device
      end

      it 'returns the browser' do
        expect(subject[:browser_name]).to eq 'Safari'
      end

      it 'returns the browser details' do
        expect(subject[:browser_details]).to eq 'Safari Version 14.1.1'
      end
    end

    context 'when the viewport is set' do
      subject do
        fixture = recording_fixture.dup
        fixture[:viewport_x] = 1920
        fixture[:viewport_y] = 1080
        described_class.new(fixture).device
      end

      it 'returns the viewport' do
        expect(subject[:viewport_x]).to eq 1920
        expect(subject[:viewport_y]).to eq 1080
      end
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

  describe '#country_name' do
    context 'when no country code is stored' do
      let(:recording) { described_class.new }

      subject { recording.country_name }

      it 'returns nil' do
        expect(subject).to eq nil
      end
    end

    context 'when no country code is stored but is nonesense' do
      let(:recording) { described_class.new(country_code: 'Hippo') }

      subject { recording.country_name }

      it 'returns nil' do
        expect(subject).to eq 'Unknown'
      end
    end

    context 'when no country code is stored' do
      let(:recording) { described_class.new(country_code: 'GB') }

      subject { recording.country_name }

      it 'returns the country' do
        expect(subject).to eq 'United Kingdom'
      end
    end
  end
end
