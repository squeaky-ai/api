# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

events_fixture = [
  {
    type: 'pageview',
    locale: 'en-GB',
    href: '/',
    useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) \
    Version/14.1.1 Safari/605.1.15',
    viewport_x: 1920,
    viewport_y: 1080,
    time: 0,
    timestamp: 162_538_814_178_1
  },
  {
    type: 'click',
    selector: 'body',
    node: 'body',
    time: 0,
    timestamp: 162_538_814_178_2
  }
]

RSpec.describe EventsJob, type: :job do
  include ActiveJob::TestHelper

  context 'when the recording is new' do
    let(:site) { create_site }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }

    let(:event) do
      {
        viewer: {
          site_id: site.uuid,
          viewer_id: viewer_id,
          session_id: session_id
        },
        events: events_fixture
      }
    end

    before { allow(SearchClient).to receive(:update) }

    subject { described_class.perform_now(event.to_json) }

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
        browser: 'Safari',
        browser_string: 'Safari Version 14.1.1',
        viewport_x: 1920,
        viewport_y: 1080,
        date_string: '4th July 2021',
        timestamp: 162_538_814_100_0
      )
    end

    it 'stores the events in redis' do
      expect { subject }.to change { Event.new(site.id.to_s, session_id).list.size }.from(0).to(2)
    end

    it 'indexes the recording into elasticsearch' do
      subject
      expect(SearchClient).to have_received(:update).with(
        index: Recording::INDEX,
        id: "#{site.id}_#{viewer_id}_#{session_id}",
        body: {
          doc: site.reload.recordings.first.to_h,
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
      {
        viewer: {
          site_id: site.uuid,
          viewer_id: viewer_id,
          session_id: session_id
        },
        events: events_fixture
      }
    end

    before do
      allow(SearchClient).to receive(:update)

      Recording.create(
        site_id: site.id,
        session_id: session_id,
        viewer_id: viewer_id,
        locale: 'en-GB',
        page_views: ['/test'],
        useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) \
        Version/14.1.1 Safari/605.1.15',
        viewport_x: 1920,
        viewport_y: 1080,
        connected_at: DateTime.new(2021, 7, 4, 9, 0, 0),
        disconnected_at: DateTime.new(2021, 7, 4, 9, 0, 0)
      )
    end

    subject { described_class.perform_now(event.to_json) }

    it 'updates the page_views' do
      expect { subject }.to change { site.recordings.first.page_views }.from(['/test']).to(['/test', '/'])
    end

    it 'updates the disconnected_at' do
      expect { subject }.to change { site.recordings.first.disconnected_at }
    end

    it 'stores the events in redis' do
      expect { subject }.to change { Event.new(site.id.to_s, session_id).list.size }.from(0).to(2)
    end

    it 'indexes the recording into elasticsearch' do
      subject
      expect(SearchClient).to have_received(:update).with(
        index: Recording::INDEX,
        id: "#{site.id}_#{viewer_id}_#{session_id}",
        body: {
          doc: site.reload.recordings.first.to_h,
          doc_as_upsert: true
        }
      )
    end
  end
end
