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
      page_views: ['/'],
      useragent: Faker::Internet.user_agent,
      viewport_x: 1920,
      viewport_y: 1080,
      connected_at: DateTime.new(2021, 7, 3, 12, 0, 0),
      disconnected_at: DateTime.new(2021, 7, 3, 12, 0, 5)
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
        timestamp
      ]
    end
  end

  describe '#stamp' do
    let(:page_view) { '/contact' }
    let(:timestamp) { Time.now.to_i * 1000 }
    let(:instance) { described_class.new(recording_fixture) }

    before { instance.save }

    subject { instance.stamp(page_view, timestamp) }

    it 'updates the page_views' do
      expect { subject }.to change { instance.page_views }.from(['/']).to(['/', '/contact'])
    end

    it 'updates the disconnected_at' do
      expect { subject }.to change { instance.disconnected_at }
    end

    it 'returns self' do
      expect(subject).to be_instance_of(Recording)
    end
  end

  describe '#user_agent' do
    subject do
      fixture = recording_fixture.dup
      fixture[:useragent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 \
      (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
      described_class.new(fixture)
    end

    it 'returns an instance of UserAgent' do
      expect(subject.user_agent).to be_instance_of(UserAgent::Browsers::Webkit)
    end
  end

  describe '#page_count' do
    subject do
      fixture = recording_fixture.dup
      fixture[:page_views] = ['/', '/pricing', '/pricing/test']
      described_class.new(fixture)
    end

    it 'returns the number of pages visited' do
      expect(subject.page_count).to eq 3
    end
  end

  describe '#duration' do
    subject { described_class.new(recording_fixture) }

    it 'returns the difference between the connected and disconnected dates' do
      expect(subject.duration).to eq 5
    end
  end

  describe '#duration_string' do
    subject { described_class.new(recording_fixture) }

    it 'returns the difference in a formatted string' do
      expect(subject.duration_string).to eq '00:05'
    end
  end

  describe '#device_type' do
    context 'when the device is a computer' do
      subject do
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
      subject do
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
    subject do
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
    subject do
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
      subject do
        fixture = recording_fixture.dup
        fixture['locale'] = 'en-gb'
        described_class.new(fixture)
      end

      it 'returns the language' do
        expect(subject.language).to eq 'English (GB)'
      end
    end

    context 'when the locale is not known' do
      subject do
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
    subject { described_class.new(recording_fixture) }

    it 'returns a nicely formatted date' do
      expect(subject.date_string).to eq '3rd July 2021'
    end
  end

  describe '#events' do
    context 'when there are no events' do
      subject { described_class.new(recording_fixture).events }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    context 'when there are some events' do
      let(:site) { create_site }

      let(:instance) do
        fixture = recording_fixture.dup
        fixture[:site_id] = site.id
        described_class.new(fixture)
      end

      before { create_events(count: 5, site_id: site.id, session_id: instance.session_id) }

      subject { instance.events }

      it 'returns the events' do
        expect(subject.size).to eq(5)
      end
    end
  end
end
