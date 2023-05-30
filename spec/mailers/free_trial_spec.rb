# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FreeTrialMailer, type: :mailer do
  describe '#first' do
    let(:owner) { create(:user) }
    let(:site) { create(:site_with_team, owner:) }
    let(:site_id) { site.id }
    let(:mail) { described_class.first(site_id) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your free trial of Squeaky\'s paid features has started...'
      expect(mail.to).to eq [site.owner.user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the site does not exist any more' do
      let(:site_id) { 234234234234 }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user has onboarding communication disabled' do
      before { create(:communication, user: owner, onboarding_email: false) }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the site is on a paid plan' do
      before { site.plan.update(plan_id: 'f20c93ec-172f-46c6-914e-6a00dff3ae5f') }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end
  end

  describe '#second' do
    let(:owner) { create(:user) }
    let(:site) { create(:site_with_team, owner:) }
    let(:site_id) { site.id }
    let(:mail) { described_class.second(site_id) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'You\'re halfway through your advanced features trial - are you making the most of it?'
      expect(mail.to).to eq [site.owner.user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the site does not exist any more' do
      let(:site_id) { 234234234234 }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user has onboarding communication disabled' do
      before { create(:communication, user: owner, onboarding_email: false) }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the site is on a paid plan' do
      before { site.plan.update(plan_id: 'f20c93ec-172f-46c6-914e-6a00dff3ae5f') }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end
  end

  describe '#third' do
    let(:owner) { create(:user) }
    let(:site) { create(:site_with_team, owner:) }
    let(:site_id) { site.id }
    let(:mail) { described_class.third(site_id) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Only 2 days left - maximize your Squeaky experience'
      expect(mail.to).to eq [site.owner.user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the site does not exist any more' do
      let(:site_id) { 234234234234 }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user has onboarding communication disabled' do
      before { create(:communication, user: owner, onboarding_email: false) }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the site is on a paid plan' do
      before { site.plan.update(plan_id: 'f20c93ec-172f-46c6-914e-6a00dff3ae5f') }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end
  end

  describe '#forth' do
    let(:owner) { create(:user) }
    let(:site) { create(:site_with_team, owner:) }
    let(:site_id) { site.id }
    let(:mail) { described_class.forth(site_id) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your trial of Squeaky\'s premium features has ended...'
      expect(mail.to).to eq [site.owner.user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the site does not exist any more' do
      let(:site_id) { 234234234234 }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user has onboarding communication disabled' do
      before { create(:communication, user: owner, onboarding_email: false) }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the site is on a paid plan' do
      before { site.plan.update(plan_id: 'f20c93ec-172f-46c6-914e-6a00dff3ae5f') }

      it 'does not send' do
        expect(mail.to).to eq nil
      end
    end
  end
end
