# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FreeTrialMailerService do
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
        .with('FreeTrialMailer', 'first', 'deliver_now', { args: [site.id] })
        .at(now + 24.hours)
      expect(ActionMailer::MailDeliveryJob)
        .to have_been_enqueued
        .with('FreeTrialMailer', 'second', 'deliver_now', { args: [site.id] })
        .at(now + 168.hours)
      expect(ActionMailer::MailDeliveryJob)
        .to have_been_enqueued
        .with('FreeTrialMailer', 'third', 'deliver_now', { args: [site.id] })
        .at(now + 288.hours)
      expect(ActionMailer::MailDeliveryJob)
        .to have_been_enqueued
        .with('FreeTrialMailer', 'forth', 'deliver_now', { args: [site.id] })
        .at(now + 336.hours)
    end
  end
end
