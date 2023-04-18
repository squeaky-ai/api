# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OnboardingMailerService do
  describe '.enqueue' do
    ActiveJob::Base.queue_adapter = :test

    context 'when the user is an owner of a site' do
      let(:now) { Time.now }
      let(:site) { create(:site_with_team) }
      let(:user) { site.owner.user }

      before { allow(Time).to receive(:now).and_return(now) }

      subject { described_class.enqueue(user) }

      it 'enqueues the emails for an owner' do
        subject
        
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'welcome', 'deliver_now', { args: [user.id] })
          .at(now + 5.minutes)
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'getting_started', 'deliver_now', { args: [user.id] })
          .at(now + 24.hours)
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'book_demo', 'deliver_now', { args: [user.id] })
          .at(now + 48.hours)
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'install_tracking_code', 'deliver_now', { args: [user.id] })
          .at(now + 96.hours)
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'tracking_code_not_installed', 'deliver_now', { args: [user.id] })
          .at(now + 240.hours)
      end
    end

    context 'when the user is an admin of a site' do
      let(:now) { Time.now }
      let(:site) { create(:site_with_team) }
      let(:team) { create(:team, site:, role: Team::ADMIN) }
      let(:user) { team.user }

      before { allow(Time).to receive(:now).and_return(now) }

      subject { described_class.enqueue(user) }

      it 'enqueues the emails for an admin' do
        subject
        
        expect(ActionMailer::MailDeliveryJob)
          .not_to have_been_enqueued
          .with('OnboardingMailer', 'welcome', 'deliver_now', { args: [user.id] })
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'getting_started', 'deliver_now', { args: [user.id] })
          .at(now)
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'book_demo', 'deliver_now', { args: [user.id] })
          .at(now + 48.hours)
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'install_tracking_code', 'deliver_now', { args: [user.id] })
          .at(now + 96.hours)
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'tracking_code_not_installed', 'deliver_now', { args: [user.id] })
          .at(now + 240.hours)
      end
    end

    context 'when the user is a member of a site' do
      let(:now) { Time.now }
      let(:site) { create(:site_with_team) }
      let(:team) { create(:team, site:, role: Team::MEMBER) }
      let(:user) { team.user }

      before { allow(Time).to receive(:now).and_return(now) }

      subject { described_class.enqueue(user) }

      it 'enqueues the emails for a member' do
        subject

        expect(ActionMailer::MailDeliveryJob)
          .not_to have_been_enqueued
          .with('OnboardingMailer', 'welcome', 'deliver_now', { args: [user.id] })
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'getting_started', 'deliver_now', { args: [user.id] })
          .at(now)
        expect(ActionMailer::MailDeliveryJob)
          .not_to have_been_enqueued
          .with('OnboardingMailer', 'book_demo', 'deliver_now', { args: [user.id] })
        expect(ActionMailer::MailDeliveryJob)
          .not_to have_been_enqueued
          .with('OnboardingMailer', 'install_tracking_code', 'deliver_now', { args: [user.id] })
        expect(ActionMailer::MailDeliveryJob)
          .not_to have_been_enqueued
          .with('OnboardingMailer', 'tracking_code_not_installed', 'deliver_now', { args: [user.id] })
      end
    end

    context 'when the user is not part of any site' do
      let(:now) { Time.now }
      let(:user) { create(:user) }

      before { allow(Time).to receive(:now).and_return(now) }

      subject { described_class.enqueue(user) }

      it 'enqueues the emails assuming they will become an owner' do
        subject

        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'welcome', 'deliver_now', { args: [user.id] })
          .at(now + 5.minutes)
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'getting_started', 'deliver_now', { args: [user.id] })
          .at(now + 24.hours)
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'book_demo', 'deliver_now', { args: [user.id] })
          .at(now + 48.hours)
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'install_tracking_code', 'deliver_now', { args: [user.id] })
          .at(now + 96.hours)
        expect(ActionMailer::MailDeliveryJob)
          .to have_been_enqueued
          .with('OnboardingMailer', 'tracking_code_not_installed', 'deliver_now', { args: [user.id] })
          .at(now + 240.hours)
      end
    end
  end
end
