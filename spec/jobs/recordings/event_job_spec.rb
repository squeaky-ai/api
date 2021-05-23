# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recordings::EventJob, type: :job do
  include ActiveJob::TestHelper

  context 'when the event is the first of this session' do
    let(:site) { create_site }
    let(:event) { new_recording_event }

    let(:context) do
      {
        site_id: site.id,
        viewer_id: SecureRandom.uuid,
        session_id: SecureRandom.uuid
      }
    end

    subject { described_class.perform_later({ **event, **context }) }

    it 'creates the recording' do
      expect { perform_enqueued_jobs { subject } }.to change { site.reload.recordings.size }.from(0).to(1)
    end

    it 'sets the start page as the path' do
      perform_enqueued_jobs { subject }
      expect(site.reload.recordings[0].start_page).to eq(event[:path])
    end

    it 'sets the exit page as the path' do
      perform_enqueued_jobs { subject }
      expect(site.reload.recordings[0].exit_page).to eq(event[:path])
    end

    it 'adds the path to the page_views' do
      perform_enqueued_jobs { subject }
      expect(site.reload.recordings[0].page_views).to eq([event[:path]])
    end
  end

  context 'when the event is not the first of the session' do
    let(:site) { create_site }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }
    let(:event) { new_recording_event({ path: '/contact' }) }

    let(:context) do
      {
        site_id: site.id,
        viewer_id: viewer_id,
        session_id: session_id
      }
    end

    subject { described_class.perform_later({ **event, **context }) }

    before do
      args = { session_id: session_id, viewer_id: viewer_id }
      create_recording(args, site: site)
    end

    it 'creates the recording' do
      expect { perform_enqueued_jobs { subject } }.not_to change { site.reload.recordings.size }
    end

    it 'does not update the start page' do
      perform_enqueued_jobs { subject }
      expect(site.reload.recordings[0].start_page).not_to eq event[:path]
    end

    it 'sets the exit page as the path' do
      perform_enqueued_jobs { subject }
      expect(site.reload.recordings[0].exit_page).to eq event[:path]
    end

    it 'adds the path to the page_views' do
      perform_enqueued_jobs { subject }
      expect(site.reload.recordings[0].page_views).to eq(['/', event[:path]])
    end
  end

  context 'when there are events in the payload' do
    let(:site) { create_site }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }

    let(:event) do
      new_recording_event(
        events: [
          {
            type: 'cursor',
            x: 0,
            y: 0,
            time: 0,
            timestamp: 0
          },
          {
            type: 'click',
            selector: 'body',
            time: 0,
            timestamp: 0
          }
        ]
      )
    end

    let(:context) do
      {
        site_id: site.id,
        viewer_id: viewer_id,
        session_id: session_id
      }
    end

    subject { described_class.perform_later({ **event, **context }) }

    it 'stores the events' do
      perform_enqueued_jobs { subject }
      expect(site.reload.recordings[0].events).to eq [
        {
          'type' => 'cursor',
          'x' => 0,
          'y' => 0,
          'time' => 0,
          'timestamp' => 0
        },
        {
          'type' => 'click',
          'selector' => 'body',
          'time' => 0,
          'timestamp' => 0
        }
      ]
    end
  end
end
