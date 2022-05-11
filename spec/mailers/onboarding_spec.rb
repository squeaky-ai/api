# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OnboardingMailer, type: :mailer do
  describe '#welcome' do
    let(:user) { create(:user) }
    let(:mail) { described_class.welcome(user&.id) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'A welcome message from the Squeaky founders.'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the user has onboarding communication disabled' do
      before { create(:communication, user:, onboarding_email: false) }
  
      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user does not exist' do
      before { user.destroy }
  
      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end
  end

  describe '#getting_started' do
    let(:user) { create(:user) }
    let(:mail) { described_class.getting_started(user&.id) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Getting started with Squeaky.'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the user has onboarding communication disabled' do
      before { create(:communication, user:, onboarding_email: false) }
  
      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user does not exist' do
      before { user.destroy }
  
      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end
  end

  describe '#book_demo' do
    let(:user) { create(:user) }
    let(:mail) { described_class.book_demo(user&.id) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Book your 1-on-1 introductory demo.'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the user has onboarding communication disabled' do
      before { create(:communication, user:, onboarding_email: false) }
  
      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user does not exist' do
      before { user.destroy }
  
      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end
  end

  describe '#install_tracking_code' do
    let(:site) { create(:site_with_team) }
    let(:user) { site.owner.user }
    let(:mail) { described_class.install_tracking_code(user&.id) }

    before { site.unverify! }

    it 'renders the headers' do
      expect(mail.subject).to eq 'How to install your Squeaky tracking code'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the site is already verified' do
      before { site.verify! }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user has onboarding communication disabled' do
      before { create(:communication, user:, onboarding_email: false) }
  
      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user does not exist' do
      before { user.destroy }
  
      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end
  end

  describe '#tracking_code_not_installed' do
    let(:site) { create(:site_with_team) }
    let(:user) { site.owner.user }
    let(:mail) { described_class.tracking_code_not_installed(user&.id) }

    before { site.unverify! }

    it 'renders the headers' do
      expect(mail.subject).to eq 'How can we make Squeaky work for you?'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the site is already verified' do
      before { site.verify! }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user has onboarding communication disabled' do
      before { create(:communication, user:, onboarding_email: false) }
  
      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user does not exist' do
      before { user.destroy }
  
      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end
  end
end
