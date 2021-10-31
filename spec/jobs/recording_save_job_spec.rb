# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'
require_relative '../fixtures/redis_events'

RSpec.describe RecordingSaveJob, type: :job do
  include ActiveJob::TestHelper

  context 'when a recording is new' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      fixture = Fixtures::RedisEvents.new(event, now)

      fixture.create_recording
      fixture.create_page_view
      fixture.create_base_events

      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'stores the recording' do
      subject
      recording = site.reload.recordings.first

      expect(recording.locale).to eq 'en-GB'
      expect(recording.useragent).to eq 'Firefox'
      expect(recording.viewport_x).to eq 1920
      expect(recording.viewport_y).to eq 1080
      expect(recording.device_x).to eq 1920
      expect(recording.device_y).to eq 1080
      expect(recording.session_id).to eq event['session_id']
      expect(recording.referrer).to eq nil
      expect(recording.connected_at).to eq now
      expect(recording.disconnected_at).to eq now + 6834
    end

    it 'stores the page' do
      subject
      pages = site.reload.recordings.first.pages

      expect(pages.size).to eq 1 
      expect(pages[0].url).to eq '/'
      expect(pages[0].entered_at).to eq now
      expect(pages[0].exited_at).to eq now + 6834
    end

    it 'stores the events' do
      subject
      expect(site.reload.recordings.first.events.size).to eq 34
    end

    it 'indexes to elasticsearch' do
      subject
      expect(SearchClient).to have_received(:bulk)
    end
  end

  context 'when a recording already exists' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    let(:visitor) { create_visitor(visitor_id: event['visitor_id']) }
    let(:recording) { create_recording({ session_id: event['session_id'] }, visitor: visitor, site: site) }

    before do
      recording
      fixture = Fixtures::RedisEvents.new(event, now)

      fixture.create_recording
      fixture.create_page_view
      fixture.create_base_events

      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'updates the existing recording' do
      subject

      expect(site.recordings.first.connected_at).to eq recording.connected_at
      expect(site.recordings.first.disconnected_at).to eq(now + 6834)
    end

    it 'does not create a new recording' do
      expect { subject }.not_to change { site.recordings.size }
    end

    it 'indexes to elasticsearch' do
      subject
      expect(SearchClient).to have_received(:bulk)
    end
  end

  context 'when the recording has no events' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      fixture = Fixtures::RedisEvents.new(event, now)

      fixture.create_recording
      fixture.create_page_view
    end

    subject { described_class.perform_now(event.to_json) }

    it 'does not save the recording' do
      expect { subject }.not_to change { site.reload.recordings.size }
    end
  end

  context 'when the visitor has external attributes set' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      fixture = Fixtures::RedisEvents.new(event, now)

      fixture.create_recording
      fixture.create_identify({ id: 1, email: 'foo@bar.com' }.to_json)
      fixture.create_page_view
      fixture.create_base_events

      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'stores the attributes with the visitor' do
      subject

      expect(site.reload.visitors.first.external_attributes).to eq('id' => '1', 'email' => 'foo@bar.com')
    end

    it 'indexes to elasticsearch' do
      subject
      expect(SearchClient).to have_received(:bulk)
    end
  end

  context 'when the visitor already exists but has updated attributes' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    let(:visitor) { create_visitor(visitor_id: event['visitor_id'], external_attributes: { id: 1, email: 'bar@baz.com' }) }
    let(:recording) { create_recording({ session_id: event['session_id'] }, visitor: visitor, site: site) }

    before do
      recording
      fixture = Fixtures::RedisEvents.new(event, now)

      fixture.create_recording
      fixture.create_identify({ id: 1, email: 'foo@bar.com' }.to_json)
      fixture.create_page_view
      fixture.create_base_events

      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'stores the attributes with the visitor' do
      subject

      expect(site.reload.visitors.first.external_attributes).to eq('id' => '1', 'email' => 'foo@bar.com')
    end

    it 'updates the existing users attributes' do
      expect { subject }.to change { visitor.reload.external_attributes['email'] }.from('bar@baz.com').to('foo@bar.com')
    end

    it 'indexes to elasticsearch' do
      subject
      expect(SearchClient).to have_received(:bulk)
    end
  end

  context 'when the duration is less than 3 seconds' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      fixture = Fixtures::RedisEvents.new(event, now)

      fixture.create_recording
      fixture.create_page_view

      fixture.create_event(timestamp: now)
      fixture.create_event(timestamp: now + 1000)

      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'stores the recording as soft deleted' do
      subject

      expect(site.reload.recordings.first.deleted).to eq true
    end

    it 'does not index to elasticsearch' do
      subject
      expect(SearchClient).not_to have_received(:bulk)
    end
  end

  context 'when the user did not interact with anything' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      fixture = Fixtures::RedisEvents.new(event, now)

      fixture.create_recording
      fixture.create_page_view

      fixture.create_event(timestamp: now)
      fixture.create_event(timestamp: now + 5000)

      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'stores the recording as soft deleted' do
      subject

      expect(site.reload.recordings.first.deleted).to eq true
    end

    it 'does not index to elasticsearch' do
      subject
      expect(SearchClient).not_to have_received(:bulk)
    end
  end

  context 'when the linked email matches a blacklisted domain' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      site.domain_blacklist << { type: 'domain', value: 'bar.com' }
      site.save

      fixture = Fixtures::RedisEvents.new(event, now)

      fixture.create_recording
      fixture.create_identify({ id: 1, email: 'foo@bar.com' }.to_json)
      fixture.create_page_view
      fixture.create_base_events

      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'does not save the recording' do
      expect { subject }.not_to change { site.reload.recordings.size }
    end

    it 'does not index to elasticsearch' do
      subject
      expect(SearchClient).not_to have_received(:bulk)
    end
  end

  context 'when the linked email does not match a blacklisted domain' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      site.domain_blacklist << { type: 'domain', value: 'teapot.com' }
      site.save

      fixture = Fixtures::RedisEvents.new(event, now)

      fixture.create_recording
      fixture.create_identify({ id: 1, email: 'foo@bar.com' }.to_json)
      fixture.create_page_view
      fixture.create_base_events

      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'saves the recording' do
      expect { subject }.to change { site.reload.recordings.size }.from(0).to(1)
    end

    it 'indexes to elasticsearch' do
      subject
      expect(SearchClient).to have_received(:bulk)
    end
  end

  context 'when the linked email matches a blacklisted email' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      site.domain_blacklist << { type: 'email', value: 'foo@bar.com' }
      site.save

      fixture = Fixtures::RedisEvents.new(event, now)

      fixture.create_recording
      fixture.create_identify({ id: 1, email: 'foo@bar.com' }.to_json)
      fixture.create_page_view
      fixture.create_base_events

      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'does not save the recording' do
      expect { subject }.not_to change { site.reload.recordings.size }
    end

    it 'does not index to elasticsearch' do
      subject
      expect(SearchClient).not_to have_received(:bulk)
    end
  end

  context 'when the linked email does not match a blacklisted domain' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      site.domain_blacklist << { type: 'email', value: 'foo@teapot.com' }
      site.save

      fixture = Fixtures::RedisEvents.new(event, now)

      fixture.create_recording
      fixture.create_identify({ id: 1, email: 'foo@bar.com' }.to_json)
      fixture.create_page_view
      fixture.create_base_events

      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'saves the recording' do
      expect { subject }.to change { site.reload.recordings.size }.from(0).to(1)
    end

    it 'indexes to elasticsearch' do
      subject
      expect(SearchClient).to have_received(:bulk)
    end
  end

  context 'when a referrer exists with the recording' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      fixture = Fixtures::RedisEvents.new(event, now)

      fixture.create_recording(referrer: 'http://google.com')
      fixture.create_page_view
      fixture.create_base_events

      allow(SearchClient).to receive(:bulk)
    end

    subject { described_class.perform_now(event.to_json) }

    it 'stores the referrer with the recording' do
      subject
      recording = site.reload.recordings.first

      expect(recording.referrer).to eq 'http://google.com'
    end
  end
end
