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
      let(:site) { create_site_and_team(subject, role: 0) }

      it 'returns false' do
        expect(subject.admin_for?(site)).to be false
      end
    end

    context 'when the user is an admin' do
      let(:subject) { create_user }
      let(:site) { create_site_and_team(subject, role: 1) }

      it 'returns true' do
        expect(subject.admin_for?(site)).to be true
      end
    end

    context 'when the user is the owner' do
      let(:subject) { create_user }
      let(:site) { create_site_and_team(subject, role: 2) }

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
      let(:site) { create_site_and_team(subject) }

      it 'returns true' do
        expect(subject.member_of?(site)).to be true
      end
    end
  end
end
