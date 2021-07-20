# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

event_fixture = {
  type: Event::META, 
  data: {
    href: 'http://localhost:8080/',
    width: 1920,
    height: 1080,
    locale: 'en-gb',
    useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:91.0) Gecko/20100101 Firefox/91.0'
  },
  timestamp: 1626272709481
}

RSpec.describe EventsJob, type: :job do
  include ActiveJob::TestHelper

  context 'when the recording is new' do
    let(:site) { create_site }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }

    let(:event) do
      gzip(
        viewer: {
          site_id: site.uuid,
          viewer_id: viewer_id,
          session_id: session_id
        },
        event: event_fixture
      )
    end

    before { allow(SearchClient).to receive(:update) }

    subject { described_class.perform_now(event) }

    it 'creates the new recording' do
      expect { subject }.to change { Site.find(site.id).recordings.size }.from(0).to(1)
    end

    it 'sets the expected data for the recording' do
      subject
      recording = site.reload.recordings.first

      expect(recording.to_h).to eq(
        id: session_id,
        site_id: site.id.to_s,
        viewer_id: viewer_id,
        active: false,
        language: 'English (GB)',
        duration: 0,
        duration_string: '00:00',
        pages: ['/'],
        page_count: 1,
        start_page: '/',
        exit_page: '/',
        device_type: 'Computer',
        browser: 'Firefox',
        browser_string: 'Firefox Version 91.0',
        viewport_x: 1920,
        viewport_y: 1080,
        date_string: '14th July 2021',
        tags: [],
        notes: [],
        timestamp: 1626272709481,
        events: recording.events.map(&:to_h).to_json
      )
    end

    it 'stores the events in redis' do
      subject
      expect(site.reload.recordings.first.events.size).to eq 1
    end

    it 'indexes the recording into elasticsearch' do
      subject

      doc = site.reload.recordings.first.to_h.except(:tags, :notes, :events)

      expect(SearchClient).to have_received(:update).with(
        index: Recording::INDEX,
        id: "#{site.id}_#{viewer_id}_#{session_id}",
        retry_on_conflict: 3,
        body: {
          doc: doc,
          doc_as_upsert: true
        }
      )
    end
  end

  context 'when the recording is part of an ongoing session' do
    let(:site) { create_site }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }

    let(:event) do
      gzip(
        viewer: {
          site_id: site.uuid,
          viewer_id: viewer_id,
          session_id: session_id
        },
        event: event_fixture
      )
    end

    before do
      allow(SearchClient).to receive(:update)

      recording = Recording.create(
        site_id: site.id,
        session_id: session_id,
        viewer_id: viewer_id
      )

      data = { 
        href: 'http://localhost:8080/test', 
        width: 1920, 
        height: 1080, 
        locale: 'en-gb', 
        useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:91.0) Gecko/20100101 Firefox/91.0' 
      }

      recording.events << Event.new(recording: recording, event_type: 4, data: data, timestamp: 1626272709480)
    end

    subject { described_class.perform_now(event) }

    it 'updates the page_views' do
      expect { subject }.to change { site.recordings.first.page_views }.from(['/test']).to(['/test', '/'])
    end

    it 'updates the disconnected_at' do
      expect { subject }.to change { site.recordings.first.disconnected_at }
    end

    it 'stores the events in redis' do
      expect { subject }.to change { site.recordings.first.events.size }.from(1).to(2)
    end

    it 'indexes the recording into elasticsearch' do
      subject
      
      doc = site.reload.recordings.first.to_h.except(:tags, :notes, :events)

      expect(SearchClient).to have_received(:update).with(
        index: Recording::INDEX,
        id: "#{site.id}_#{viewer_id}_#{session_id}",
        retry_on_conflict: 3,
        body: {
          doc: doc,
          doc_as_upsert: true
        }
      )
    end
  end

  context 'when the payload does not contain any META events' do
    let(:site) { create_site }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }

    let(:event) do
      gzip(
        viewer: {
          site_id: site.uuid,
          viewer_id: viewer_id,
          session_id: session_id
        },
        event: {
          type: Event::INCREMENTAL_SNAPSHOT, 
          data: {},
          timestamp: 1626272709481
        }
      )
    end

    before do
      allow(SearchClient).to receive(:update)

      recording = Recording.create(
        site_id: site.id,
        session_id: session_id,
        viewer_id: viewer_id
      )

      data = { 
        href: 'http://localhost:8080/test', 
        width: 1920, 
        height: 1080, 
        locale: 'en-gb', 
        useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:91.0) Gecko/20100101 Firefox/91.0' 
      }

      recording.events << Event.new(recording: recording, event_type: 4, data: data, timestamp: 1626272709480)
    end

    subject { described_class.perform_now(event) }

    it 'does note update elasticsearch' do
      subject

      expect(SearchClient).not_to have_received(:update)
    end
  end
end
