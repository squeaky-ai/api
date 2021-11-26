# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe RecordingSaveJob, type: :job do
  include ActiveJob::TestHelper

  context 'when the recording is new' do
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      events_fixture = File.read("#{__dir__}/../fixtures/events.json")

      allow(Redis.current).to receive(:lrange).and_return(JSON.parse(events_fixture))
      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'stores the recording' do
      subject
      recording = site.reload.recordings.first

      expect(recording.locale).to eq 'en-GB'
      expect(recording.useragent).to eq 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:95.0) Gecko/20100101 Firefox/95.0'
      expect(recording.viewport_x).to eq 1813
      expect(recording.viewport_y).to eq 1813
      expect(recording.device_x).to eq 3840
      expect(recording.device_y).to eq 1600
      expect(recording.session_id).to eq event['session_id']
      expect(recording.connected_at).to eq 1637177342265
      expect(recording.disconnected_at).to eq 1637177353431
    end

    it 'stores the page' do
      subject
      pages = site.reload.recordings.first.pages

      expect(pages.size).to eq 1 
      expect(pages[0].url).to eq '/examples/static/'
      expect(pages[0].entered_at).to eq 1637177342265
      expect(pages[0].exited_at).to eq 1637177353431
    end

    it 'stores the events' do
      subject
      expect(site.reload.recordings.first.events.size).to eq 82
    end

    it 'indexes to elasticsearch' do
      subject
      expect(SearchClient).to have_received(:bulk)
    end
  end

  context 'when the email domain is blacklisted' do
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      site.domain_blacklist << { type: 'domain', value: 'gmail.com' }
      site.save

      events_fixture = File.read("#{__dir__}/../fixtures/events.json")

      allow(Redis.current).to receive(:lrange).and_return(JSON.parse(events_fixture))
      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'does not store the recording' do
      expect { subject }.not_to change { site.reload.recordings.size }
    end

    it 'does not index to elasticsearch' do
      subject
      expect(SearchClient).not_to have_received(:bulk)
    end
  end

  context 'when the email address is blacklisted' do
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      site.domain_blacklist << { type: 'email', value: 'bobdylan@gmail.com' }
      site.save

      events_fixture = File.read("#{__dir__}/../fixtures/events.json")

      allow(Redis.current).to receive(:lrange).and_return(JSON.parse(events_fixture))
      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'does not store the recording' do
      expect { subject }.not_to change { site.reload.recordings.size }
    end

    it 'does not index to elasticsearch' do
      subject
      expect(SearchClient).not_to have_received(:bulk)
    end
  end
end
