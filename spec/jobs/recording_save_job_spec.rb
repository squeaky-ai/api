# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe RecordingSaveJob, type: :job do
  include ActiveJob::TestHelper

  context 'when the recording is new' do
    let(:site) { create(:site_with_team) }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      events_fixture = File.read("#{__dir__}/../fixtures/events.json")

      allow(Cache.redis).to receive(:lrange).and_return(JSON.parse(events_fixture))
      allow(Cache.redis).to receive(:del)
    end

    subject { described_class.perform_now(event) }

    it 'stores the recording' do
      subject
      recording = site.reload.recordings.first

      expect(recording.locale).to eq 'en-GB'
      expect(recording.useragent).to eq 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:95.0) Gecko/20100101 Firefox/95.0'
      expect(recording.viewport_x).to eq 1813
      expect(recording.viewport_y).to eq 1813
      expect(recording.device_x).to eq 3840
      expect(recording.device_y).to eq 1600
      expect(recording.timezone).to eq 'Europe/London'
      expect(recording.country_code).to eq 'GB'
      expect(recording.session_id).to eq event['session_id']
      expect(recording.connected_at).to eq Time.at(1637177342265 / 1000).utc
      expect(recording.disconnected_at).to eq Time.at(1637177353431 / 1000).utc
      expect(recording.pages_count).to eq 1
    end

    it 'stores the page' do
      subject
      pages = site.reload.recordings.first.pages

      expect(pages.size).to eq 1
      expect(pages[0].url).to eq '/examples/static/'
      expect(pages[0].entered_at).to eq Time.at(1637177342265 / 1000).utc
      expect(pages[0].exited_at).to eq Time.at(1637177353431 / 1000).utc
    end

    it 'stores the events' do
      subject
      expect(site.reload.recordings.first.events.size).to eq 82
    end

    it 'stores the sentiments' do
      subject
      sentiment = site.reload.sentiments.first
      expect(sentiment.score).to eq 2
      expect(sentiment.comment).to eq 'Hello'
    end

    it 'stores the nps' do
      subject
      nps = site.reload.nps.first
      expect(nps.score).to eq 9
      expect(nps.comment).to eq 'Hello'
      expect(nps.contact).to eq true
      expect(nps.email).to eq 'bobby@gmail.com'
    end

    it 'cleans up the redis data' do
      subject
      expect(Cache.redis).to have_received(:del)
    end
  end

  context 'when the email domain is blacklisted' do
    let(:site) { create(:site_with_team) }

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

      allow(Cache.redis).to receive(:lrange).and_return(JSON.parse(events_fixture))
    end

    subject { described_class.perform_now(event) }

    it 'does not store the recording' do
      expect { subject }.not_to change { site.reload.recordings.size }
    end
  end

  context 'when the email address is blacklisted' do
    let(:site) { create(:site_with_team) }

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

      allow(Cache.redis).to receive(:lrange).and_return(JSON.parse(events_fixture))
    end

    subject { described_class.perform_now(event) }

    it 'does not store the recording' do
      expect { subject }.not_to change { site.reload.recordings.size }
    end
  end

  context 'when the site recording limit has been exceeded' do
    let(:site) { create(:site_with_team) }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      events_fixture = File.read("#{__dir__}/../fixtures/events.json")

      allow(Cache.redis).to receive(:lrange).and_return(JSON.parse(events_fixture))
      allow_any_instance_of(Site).to receive(:recording_count_exceeded?).and_return(true)
      allow(PlanService).to receive(:alert_if_exceeded).and_call_original
    end

    subject { described_class.perform_now(event) }

    it 'saves the recording with the LOCKED status' do
      subject
      recording = site.reload.recordings.first
      expect(recording.status).to eq Recording::LOCKED
    end

    it 'checks if the exceeded email needs to be send' do
      subject
      expect(PlanService).to have_received(:alert_if_exceeded)
    end
  end

  context 'when the customer has not paid their bill' do
    let(:site) { create(:site_with_team) }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      events_fixture = File.read("#{__dir__}/../fixtures/events.json")

      allow(Cache.redis).to receive(:lrange).and_return(JSON.parse(events_fixture))
      allow_any_instance_of(Site).to receive(:recording_count_exceeded?).and_return(true)

      create(:billing, site: site, status: Billing::INVALID)
    end

    subject { described_class.perform_now(event) }

    it 'saves the recording with the LOCKED status' do
      subject
      recording = site.reload.recordings.first
      expect(recording.status).to eq Recording::LOCKED
    end
  end

  context 'when the site was not verified' do
    let(:site) { create(:site_with_team) }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      site.update(verified_at: nil)
      events_fixture = File.read("#{__dir__}/../fixtures/events.json")

      allow(Cache.redis).to receive(:lrange).and_return(JSON.parse(events_fixture))
    end

    subject { described_class.perform_now(event) }

    it 'verifies it' do
      expect { subject }.to change { site.reload.verified_at.nil? }.from(true).to(false)
    end
  end
end
