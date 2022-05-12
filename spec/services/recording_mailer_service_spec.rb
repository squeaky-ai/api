# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordingMailerService do
  describe '.enqueue' do
    ActiveJob::Base.queue_adapter = :test

    let(:now) { Time.now }
    let(:site) { create(:site_with_team) }

    before { allow(Time).to receive(:now).and_return(now) }

    subject { described_class.enqueue(site) }

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
end
