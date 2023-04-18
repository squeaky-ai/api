# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordingMailerService do
  describe '.enqueue_if_first_recording' do
    ActiveJob::Base.queue_adapter = :test

    context 'when the recording is the first' do
      let(:now) { Time.now }
      let(:site) { create(:site_with_team) }

      before do
        allow(Time).to receive(:now).and_return(now)

        create(:recording, site:)
      end

      subject { described_class.enqueue_if_first_recording(site) }

      it 'enqueues the emails' do
        subject

        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('RecordingMailer', 'first_recording', 'deliver_now', { args: [site.id] })
          .at(now)
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('RecordingMailer', 'first_recording_followup', 'deliver_now', { args: [site.id] })
          .at(now + 24.hours)
      end
    end

    context 'when the recording is not the first' do
      let(:now) { Time.now }
      let(:site) { create(:site_with_team) }

      before do
        allow(Time).to receive(:now).and_return(now)

        create(:recording, site:)
        create(:recording, site:)
      end

      subject { described_class.enqueue_if_first_recording(site) }

      it 'does not enqueue the emails' do
        expect(ActionMailer::MailDeliveryJob)
          .not_to have_been_enqueued
          .with('RecordingMailer', 'first_recording', 'deliver_now', { args: [site.id] })
        expect(ActionMailer::MailDeliveryJob)
          .not_to have_been_enqueued
          .with('RecordingMailer', 'first_recording_followup', 'deliver_now', { args: [site.id] })
      end
    end
  end
end
