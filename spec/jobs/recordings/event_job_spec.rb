# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recordings::EventJob, type: :job do
  include ActiveJob::TestHelper

  context 'when creating the first event' do
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
      event = Recordings::Event.new(context)
      expect { perform_enqueued_jobs { subject } }.to change { event.list(0, 5).size }.from(0).to(1)
    end
  end

  context 'when events already exist' do
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

    before do
      3.times { Recordings::Event.new(context).add({}) }
    end

    it 'creates the recording' do
      event = Recordings::Event.new(context)
      expect { perform_enqueued_jobs { subject } }.to change { event.list(0, 5).size }.from(3).to(4)
    end
  end
end
