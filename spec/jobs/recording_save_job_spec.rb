# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordingSaveJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
    allow(Cache.redis).to receive(:lrange).and_return(events_fixture)
  end

  let(:s3_client) { instance_double(Aws::S3::Client, put_object: nil) }
  let(:events_fixture) { require_fixture('events.json', compress: true) }

  let(:site) { create(:site_with_team) }

  let(:event) do
    {
      'site_id' => site.uuid,
      'session_id' => SecureRandom.base36,
      'visitor_id' => SecureRandom.base36
    }
  end

  context 'when the recording is new' do
    before do
      allow(Cache.redis).to receive(:del)
      allow(Cache.redis).to receive(:set)
      allow(Cache.redis).to receive(:expire)

      allow(RecordingMailerService).to receive(:enqueue_if_first_recording)
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
      expect(recording.utm_source).to eq 'google'
      expect(recording.utm_medium).to eq 'organic'
      expect(recording.utm_campaign).to eq 'my_campaign'
      expect(recording.utm_content).to eq 'test'
      expect(recording.utm_term).to eq 'analytics'
      expect(recording.inactivity).to eq []
      expect(recording.activity_duration).to eq 11166
      expect(recording.active_events_count).to eq 67
      expect(recording.events_key_prefix).to eq("#{event['site_id']}/#{event['visitor_id']}/#{event['session_id']}")
    end

    it 'stores the page' do
      subject
      pages = site.reload.recordings.first.pages

      expect(pages.size).to eq 1
      expect(pages[0].url).to eq '/examples/static/'
      expect(pages[0].entered_at).to eq Time.at(1637177342265 / 1000).utc
      expect(pages[0].exited_at).to eq Time.at(1637177353431 / 1000).utc
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

    it 'sets a lock so that duplicate jobs do not run' do
      subject

      expect(Cache.redis)
        .to have_received(:set)
        .with("job_lock::#{event['site_id']}::#{event['visitor_id']}::#{event['session_id']}", '1')

      expect(Cache.redis)
        .to have_received(:expire)
        .with("job_lock::#{event['site_id']}::#{event['visitor_id']}::#{event['session_id']}", 7200)
    end

    it 'triggers the recordings mailer' do
      subject

      expect(RecordingMailerService).to have_received(:enqueue_if_first_recording).with(site)
    end

    it 'creates the event captures' do
      expect { subject }.to change { site.reload.event_captures.size }.from(0).to(1)
    end

    it 'stores all the clickhouse data' do
      expect { subject }
        .to change { Sql::ClickHouse.select_value("SELECT COUNT(*) FROM click_events WHERE site_id = #{site.id}") }.from(0).to(3)
        .and change { Sql::ClickHouse.select_value("SELECT COUNT(*) FROM custom_events WHERE site_id = #{site.id}") }.from(0).to(1)
        .and change { Sql::ClickHouse.select_value("SELECT COUNT(*) FROM error_events WHERE site_id = #{site.id}") }.from(0).to(1)
        .and change { Sql::ClickHouse.select_value("SELECT COUNT(*) FROM page_events WHERE site_id = #{site.id}") }.from(0).to(1)
        .and change { Sql::ClickHouse.select_value("SELECT COUNT(*) FROM cursor_events WHERE site_id = #{site.id}") }.from(0).to(21)
        .and change { Sql::ClickHouse.select_value("SELECT COUNT(*) FROM scroll_events WHERE site_id = #{site.id}") }.from(0).to(40)
        .and change { Sql::ClickHouse.select_value("SELECT COUNT(*) FROM recordings WHERE site_id = #{site.id}") }.from(0).to(1)
    end

    it 'writes the events to S3' do
      subject 

      expect(s3_client).to have_received(:put_object).with(
        body: anything,
        bucket: 'events.squeaky.ai',
        key: "#{event['site_id']}/#{event['visitor_id']}/#{event['session_id']}/0.json"
      )
    end
  end

  context 'when the email domain is blacklisted' do
    before do
      site.domain_blacklist << { type: 'domain', value: 'gmail.com' }
      site.save
    end

    subject { described_class.perform_now(event) }

    it 'does not store the recording' do
      expect { subject }.not_to change { site.reload.recordings.size }
    end
  end

  context 'when the email address is blacklisted' do
    before do
      site.domain_blacklist << { type: 'email', value: 'bobdylan@gmail.com' }
      site.save
    end

    subject { described_class.perform_now(event) }

    it 'does not store the recording' do
      expect { subject }.not_to change { site.reload.recordings.size }
    end
  end

  context 'when the site recording limit has been exceeded' do
    before do
      allow(PlanService).to receive(:alert_if_exceeded).and_call_original
      allow_any_instance_of(Plan).to receive(:exceeded?).and_return(true)
    end

    subject { described_class.perform_now(event) }

    it 'checks if the exceeded email needs to be send' do
      subject
      expect(PlanService).to have_received(:alert_if_exceeded)
    end
  end

  context 'when the site was not verified' do
    before do
      site.update(verified_at: nil)
    end

    subject { described_class.perform_now(event) }

    it 'verifies it' do
      expect { subject }.to change { site.reload.verified_at.nil? }.from(true).to(false)
    end
  end

  context 'when an existing job with the same arguments has been locked' do
    before do
      site.update(verified_at: nil)

      allow(Cache.redis)
        .to receive(:get)
        .with("job_lock::#{event['site_id']}::#{event['visitor_id']}::#{event['session_id']}")
        .and_return('1')
    end

    subject { described_class.perform_now(event) }

    it 'raises an error' do
      expect { subject }.to raise_error(
        StandardError, 
        "RecordingSaveJob lock hit for job_lock::#{event['site_id']}::#{event['visitor_id']}::#{event['session_id']}"
      )
    end
  end

  context 'when the session already exists' do
    let(:session_id) { SecureRandom.base36 }
    let(:recording) { create(:recording, site:, session_id: )}

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => session_id,
        'visitor_id' => SecureRandom.base36
      }
    end

    it 'does not store the recording' do
      expect { subject }.not_to change { site.reload.recordings.size }
    end
  end

  context 'when one of the event captures already exists' do
    let!(:event_capture) { create(:event_capture, site:, name: 'my-event') }

    subject { described_class.perform_now(event) }

    it 'does not save it again' do
      expect { subject }.not_to change { site.reload.event_captures.size }
    end
  end

  context 'when calculating the activity' do
    let(:events_fixture) { require_fixture('events_with_inactivity.json', compress: false) }

    before do
      allow(Cache.redis).to receive(:del)
      allow(Cache.redis).to receive(:set)
      allow(Cache.redis).to receive(:expire)
    end

    subject { described_class.perform_now(event) }

    it 'stores the recordings activity' do
      subject
      recording = site.reload.recordings.first

      expect(recording.inactivity).to eq [['3125', '28410'], ['30426', '55402'], ['66031', '71252']]
      expect(recording.activity_duration).to eq 15770
    end
  end
end
