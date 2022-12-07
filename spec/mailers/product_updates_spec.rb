# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductUpdatesMailer, type: :mailer do
  describe 'q2_2022' do
    let(:user) { create(:user) }
    let(:mail) { described_class.q2_2022(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Product Update: Q2 2022'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the user has communication disabled' do
      before { create(:communication, user:, product_updates_email: false) }

      it 'does not send anything' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user has no name set' do
      before { user.update(first_name: nil, last_name: nil) }

      it 'does not send anything' do
        expect(mail.to).to eq nil
      end
    end
  end

  describe 'july_2022' do
    let(:user) { create(:user) }
    let(:mail) { described_class.july_2022(user) }

    before { create(:site_with_team, owner: user) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Product Update: July 2022'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the user has communication disabled' do
      before { create(:communication, user:, product_updates_email: false) }

      it 'does not send anything' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user has no name set' do
      before { user.update(first_name: nil, last_name: nil) }

      it 'does not send anything' do
        expect(mail.to).to eq nil
      end
    end
  end

  describe 'august_2022' do
    let(:user) { create(:user) }
    let(:mail) { described_class.august_2022(user) }

    before { create(:site_with_team, owner: user) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Product Update: August 2022'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the user has communication disabled' do
      before { create(:communication, user:, product_updates_email: false) }

      it 'does not send anything' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user has no name set' do
      before { user.update(first_name: nil, last_name: nil) }

      it 'does not send anything' do
        expect(mail.to).to eq nil
      end
    end
  end

  describe 'september_2022' do
    let(:user) { create(:user) }
    let(:mail) { described_class.september_2022(user) }

    before { create(:site_with_team, owner: user) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Product Update: September-October 2022'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the user has communication disabled' do
      before { create(:communication, user:, product_updates_email: false) }

      it 'does not send anything' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user has no name set' do
      before { user.update(first_name: nil, last_name: nil) }

      it 'does not send anything' do
        expect(mail.to).to eq nil
      end
    end
  end

  describe 'november_2022' do
    let(:user) { create(:user) }
    let(:mail) { described_class.november_2022(user) }

    before { create(:site_with_team, owner: user) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Product Update: November 2022'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    context 'when the user has communication disabled' do
      before { create(:communication, user:, product_updates_email: false) }

      it 'does not send anything' do
        expect(mail.to).to eq nil
      end
    end

    context 'when the user has no name set' do
      before { user.update(first_name: nil, last_name: nil) }

      it 'does not send anything' do
        expect(mail.to).to eq nil
      end
    end
  end
end
