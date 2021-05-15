# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#full_name' do
    context 'when the user has not filled out their name' do
      let(:subject) { described_class.new }

      it 'returns nil' do
        expect(subject.full_name).to be_nil
      end
    end

    context 'when the user has filled out their name' do
      let(:subject) { create_user }

      it 'returns the full name' do
        expect(subject.full_name).to eq "#{subject.first_name} #{subject.last_name}"
      end
    end
  end

  describe '#owner_for?' do
    context 'when the site nil' do
      let(:subject) { described_class.new }

      it 'returns false' do
        site = nil

        expect(subject.owner_for?(site)).to be false
      end
    end

    context 'when the user is the owner' do
      let(:subject) { create_user }
      let(:site) { create_site_and_team(user: subject, role: Team::OWNER) }

      it 'returns true' do
        expect(subject.owner_for?(site)).to be true
      end
    end

    context 'when the user is not the owner' do
      let(:subject) { create_user }
      let(:site) { create_site_and_team(user: create_user, role: Team::OWNER) }
      let(:team) { create_team(user: subject, site: site, role: Team::ADMIN) }

      it 'returns true' do
        expect(subject.owner_for?(site)).to be false
      end
    end
  end

  describe '#admin_for?' do
    context 'when the site nil' do
      let(:subject) { described_class.new }

      it 'returns false' do
        site = nil

        expect(subject.admin_for?(site)).to be false
      end
    end

    context 'when the user is a member' do
      let(:subject) { create_user }
      let(:site) { create_site_and_team(user: subject, role: Team::MEMBER) }

      it 'returns false' do
        expect(subject.admin_for?(site)).to be false
      end
    end

    context 'when the user is an admin' do
      let(:subject) { create_user }
      let(:site) { create_site_and_team(user: subject, role: Team::ADMIN) }

      it 'returns true' do
        expect(subject.admin_for?(site)).to be true
      end
    end

    context 'when the user is the owner' do
      let(:subject) { create_user }
      let(:site) { create_site_and_team(user: subject, role: Team::OWNER) }

      it 'returns true' do
        expect(subject.admin_for?(site)).to be true
      end
    end
  end

  describe '#member_of?' do
    context 'when the user is not a member of the team' do
      let(:subject) { create_user }
      let(:site) { create_site }

      it 'returns false' do
        expect(subject.member_of?(site)).to be false
      end
    end

    context 'when the user is a member of the team' do
      let(:subject) { create_user }
      let(:site) { create_site_and_team(user: subject) }

      it 'returns true' do
        expect(subject.member_of?(site)).to be true
      end
    end
  end

  describe '#site' do
    # TODO
  end
end
