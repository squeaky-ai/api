# frozen_string_literal: true

require 'date'
require 'rails_helper'
require 'securerandom'

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
      site = create_site
      recording = create_recording({ pages: [create_page(url: '/'), create_page(url: '/contact'), create_page(url: '/test')] }, site: site, visitor: create_visitor)

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
        fixture[:useragent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
        described_class.new(fixture).device
      end

      it 'returns the device type' do
        expect(subject[:device_type]).to eq 'Computer'
      end
    end

    context 'when the devise is a mobile' do
      subject do
        fixture = recording_fixture.dup
        fixture[:useragent] = 'Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1'
        described_class.new(fixture).device
      end

      it 'returns the device type' do
        expect(subject[:device_type]).to eq 'Mobile'
      end
    end

    context 'when the browser is set' do
      subject do
        fixture = recording_fixture.dup
        fixture[:useragent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
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

  describe '#previous_recording' do
    context 'when there is only one recording' do
      let(:site) { create_site }
      let(:recordings) { create_recordings(site: site, visitor: create_visitor, count: 1) }

      subject { recordings[0].previous_recording }

      it 'returns nil' do
        expect(subject).to be nil
      end
    end

    context 'when there is more than one recording' do
      context 'when this recording is the first' do
        let(:site) { create_site }
        let(:recordings) { create_recordings(site: site, visitor: create_visitor, count: 3) }

        subject { recordings.first.previous_recording }

        it 'returns nil' do
          expect(subject).to be nil
        end
      end

      context 'when this recording not the first' do
        let(:site) { create_site }
        let(:recordings) { create_recordings(site: site, visitor: create_visitor, count: 3) }

        subject { recordings[1].previous_recording }

        it 'returns the previous recording' do
          expect(subject.id).to be recordings.first.id
        end
      end
    end
  end

  describe '#next_recording' do
    context 'when there is only one recording' do
      let(:site) { create_site }
      let(:recordings) { create_recordings(site: site, visitor: create_visitor, count: 1) }

      subject { recordings.first.next_recording }

      it 'returns nil' do
        expect(subject).to be nil
      end
    end

    context 'when there is more than one recording' do
      context 'when this recording is the last' do
        let(:site) { create_site }
        let(:recordings) { create_recordings(site: site, visitor: create_visitor, count: 3) }

        subject { recordings.last.next_recording }

        it 'returns nil' do
          expect(subject).to be nil
        end
      end

      context 'when this recording not the last' do
        let(:site) { create_site }
        let(:recordings) { create_recordings(site: site, visitor: create_visitor, count: 3) }

        subject { recordings[1].next_recording }

        it 'returns the previous recording' do
          expect(subject.id).to be recordings[2].id
        end
      end
    end
  end

  describe '#to_h' do
    let(:now) { Time.new(2021, 9, 24, 12, 0, 0) }
    let(:site) { create_site }
    let(:fixture) { recording_fixture.dup.merge(site_id: site.id, created_at: now, useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15') }
    let(:visitor) { create_visitor }
    let(:recording) { create_recording(fixture, site: site, visitor: visitor) }

    before { recording }

    subject { recording.to_h }

    it 'returns the hashed version' do
      expect(subject).to eq(
        id: recording.id,
        site_id: site.id,
        session_id: recording.session_id,
        viewed: false,
        bookmarked: false,
        locale: 'en-GB', 
        language: 'English (GB)', 
        duration: 1000000,
        date_time: '2021-09-24T11:00:00Z',
        connected_at: recording.connected_at,
        disconnected_at: recording.disconnected_at,
        page_count: 1,
        page_views: ['/'],
        start_page: '/',
        exit_page: '/',
        device: {
          browser_name: 'Safari', 
          browser_details: 'Safari Version 14.1.1',
          viewport_x: 1920, 
          viewport_y: 1080,
          device_type: 'Computer',
          useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
        },
        visitor: {
          id: visitor.id,
          visitor_id: visitor.visitor_id
        }
      )
    end
  end
end
