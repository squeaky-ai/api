# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteService do
  describe '.find_by_id' do
    let(:user) { nil }
    let(:site) { nil }

    subject { described_class.find_by_id(user, site&.id) }

    before do
      allow(Rails.cache).to receive(:fetch).and_call_original
    end

    context 'when there is no user' do
      it 'raises an error' do
        expect { subject }.to raise_error(Errors::Unauthorized)
      end

      it 'does not attempt to cache anything' do
        subject rescue nil
        expect(Rails.cache).not_to have_received(:fetch)
      end
    end

    context 'when the user is a superuser' do
      let(:user) { create(:user, superuser: true) }

      context 'and the site does not exist' do
        it 'returns nil' do
          expect(subject).to be_nil
        end
      end

      context 'and the site exist' do
        context 'and the site does not have superuser access enabled' do
          let(:site) { create(:site) }

          it 'returns nil' do
            expect(subject).to be_nil
          end
        end

        context 'and the site has superuser access enabled' do
          let(:site) { create(:site, superuser_access_enabled: true) }

          it 'returns the site' do
            expect(subject).to eq site
          end
        end
      end
    end

    context 'when the user is a member of the team' do
      let(:user) { create(:user) }
      let(:site) { create(:site) }

      context 'when the invite is pending' do
        before { create(:team, site:, user:, status: Team::PENDING) }

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end

      context 'when the invite is not pending' do
        before { create(:team, site:, user:, status: Team::ACCEPTED) }

        it 'returns the site' do
          expect(subject).to eq site
        end
      end
    end

    context 'when the user is not a member of the team' do
      let(:user) { create(:user) }
      let(:site) { create(:site) }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '.find_by_uuid' do
    let(:user) { nil }
    let(:site) { nil }

    subject { described_class.find_by_uuid(user, site&.uuid) }

    before do
      allow(Rails.cache).to receive(:fetch).and_call_original
    end

    context 'when there is no user' do
      it 'returns nil' do
        expect(subject).to be_nil
      end

      it 'does not attempt to cache anything' do
        subject rescue nil
        expect(Rails.cache).not_to have_received(:fetch)
      end
    end

    context 'when the user is a member of the team' do
      let(:user) { create(:user) }
      let(:site) { create(:site) }

      context 'when the invite is pending' do
        before { create(:team, site:, user:, status: Team::PENDING) }

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end

      context 'when the invite is not pending' do
        before { create(:team, site:, user:, status: Team::ACCEPTED) }

        it 'returns the site' do
          expect(subject).to eq site
        end
      end
    end

    context 'when the user is not a member of the team' do
      let(:user) { create(:user) }
      let(:site) { create(:site) }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end
end
