# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recordings::PageViewJob, type: :job do
  include ActiveJob::TestHelper

  context 'when the PageView is the first of this session' do
    let(:site) { create_site }
    let(:event) { new_recording_page_view }

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

    it 'sets the start page as the href' do
      perform_enqueued_jobs { subject }
      expect(site.reload.recordings[0].start_page).to eq(event[:href])
    end

    it 'sets the exit page as the href' do
      perform_enqueued_jobs { subject }
      expect(site.reload.recordings[0].exit_page).to eq(event[:href])
    end

    it 'adds the href to the page_views' do
      perform_enqueued_jobs { subject }
      expect(site.reload.recordings[0].page_views).to eq([event[:href]])
    end
  end

  context 'when the event is not the first of the session' do
    let(:site) { create_site }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }
    let(:event) { new_recording_page_view({ href: '/contact' }) }

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
      expect(site.reload.recordings[0].start_page).not_to eq event[:href]
    end

    it 'sets the exit page as the href' do
      perform_enqueued_jobs { subject }
      expect(site.reload.recordings[0].exit_page).to eq event[:href]
    end

    it 'adds the href to the page_views' do
      perform_enqueued_jobs { subject }
      expect(site.reload.recordings[0].page_views).to eq(['/', event[:href]])
    end
  end
end
