# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe RecordingsJob, type: :job do
  include ActiveJob::TestHelper

  context 'when the recording does not exist' do
    let(:message) do
      {
        site_id: SecureRandom.uuid,
        session_id: SecureRandom.uuid
      }
    end

    before { allow(SearchClient).to receive(:update) }

    subject { described_class.perform_later(message.to_json) }

    it 'does not create a recording' do
      perform_enqueued_jobs { subject }
      expect(SearchClient).not_to have_received(:update)
    end
  end

  context 'when the recording does exist' do
    let(:site) { create_site }
    let(:recording) { create_recording(site: site) }

    let(:message) do
      {
        site_id: recording.site_id,
        session_id: recording.session_id
      }
    end

    before { allow(SearchClient).to receive(:update) }

    after { recording.delete! }

    subject { described_class.perform_later(message.to_json) }

    it 'creates a recording' do
      perform_enqueued_jobs { subject }

      expect(SearchClient).to have_received(:update).with(
        index: Recording::INDEX,
        id: "#{recording.site_id}_#{recording.viewer_id}_#{recording.session_id}",
        body: {
          doc: recording.serialize,
          doc_as_upsert: true
        }
      )
    end
  end
end
