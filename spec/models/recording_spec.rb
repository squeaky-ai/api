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
      fixture = recording_fixture.dup
      fixture.pages = [
        Page.new(url: '/'),
        Page.new(url: '/contact'),
        Page.new(url: '/test')
      ]
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
end
