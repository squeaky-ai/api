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

  context 'when the event_type is connected' do
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
        key: 'connected',
        value: 1626859354273
      )
    end

    before do
      recording = Recording.create(
        site_id: site.id,
        session_id: session_id,
        viewer_id: viewer_id
      )
    end

    subject { described_class.perform_now(event) }

    it 'updates the connected_at field' do
      expect { subject }.to change { site.recordings.first.connected_at }.from(nil).to(1626859354273)
    end

    it 'sets the recording as active' do
      expect { subject }.to change { site.recordings.first.active }.from(false).to(true)
    end
  end

  context 'when the event_type is disconnected' do
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
        key: 'disconnected',
        value: 1626859354273
      )
    end

    before do
      recording = Recording.create(
        site_id: site.id,
        session_id: session_id,
        viewer_id: viewer_id,
        active: true
      )
    end

    subject { described_class.perform_now(event) }

    it 'updates the disconnected_at field' do
      expect { subject }.to change { site.recordings.first.disconnected_at }.from(nil).to(1626859354273)
    end

    it 'sets the recording as inactive' do
      expect { subject }.to change { site.recordings.first.active }.from(true).to(false)
    end
  end

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
        key: 'event',
        value: event_fixture
      )
    end

    subject { described_class.perform_now(event) }

    it 'creates the new recording' do
      expect { subject }.to change { Site.find(site.id).recordings.size }.from(0).to(1)
    end

    it 'includes the session details' do
      subject
      recording = site.reload.recordings.first
      expect(recording.site_id).to eq site.id
      expect(recording.viewer_id).to eq viewer_id
      expect(recording.session_id).to eq session_id
    end

    it 'stores the event' do
      subject
      expect(site.reload.recordings.first.events.size).to eq 1
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
        key: 'event',
        value: event_fixture
      )
    end

    before do
      recording = Recording.create(
        site_id: site.id,
        session_id: session_id,
        viewer_id: viewer_id,
        page_views: ['/test'],
        connected_at: 1626859354273,
        disconnected_at: 1626859357273
      )
    end

    subject { described_class.perform_now(event) }

    it 'updates the page_views' do
      expect { subject }.to change { site.recordings.first.page_views }.from(['/test']).to(['/test', '/'])
    end

    it 'includes the session details' do
      subject
      recording = site.reload.recordings.first
      expect(recording.site_id).to eq site.id
      expect(recording.viewer_id).to eq viewer_id
      expect(recording.session_id).to eq session_id
    end

    it 'stores the events' do
      expect { subject }.to change { site.recordings.first.events.size }.from(0).to(1)
    end
  end
end
