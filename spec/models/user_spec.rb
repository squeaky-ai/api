# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#full_name' do
    context 'when the user has not filled out their name' do
      subject { described_class.new }

      it 'returns nil' do
        expect(subject.full_name).to be_nil
      end
    end

    context 'when the user has filled out their name' do
      subject { create_user }

      it 'returns the full name' do
        expect(subject.full_name).to eq "#{subject.first_name} #{subject.last_name}"
      end
    end
  end

  describe '#owner_for?' do
    context 'when the site nil' do
      subject { described_class.new }

      it 'returns false' do
        site = nil

        expect(subject.owner_for?(site)).to be false
      end
    end

    context 'when the user is the owner' do
      subject { create_user }

      let(:site) { create_site_and_team(user: subject, role: Team::OWNER) }

      it 'returns true' do
        expect(subject.owner_for?(site)).to be true
      end
    end

    context 'when the user is not the owner' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: create_user, role: Team::OWNER) }
      let(:team) { create_team(user: subject, site: site, role: Team::ADMIN) }

      subject { user }

      it 'returns true' do
        expect(subject.owner_for?(site)).to be false
      end
    end
  end

  describe '#admin_for?' do
    context 'when the site nil' do
      subject { described_class.new }

      it 'returns false' do
        site = nil

        expect(subject.admin_for?(site)).to be false
      end
    end

    context 'when the user is a member' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: subject, role: Team::MEMBER) }

      subject { user }

      it 'returns false' do
        expect(subject.admin_for?(site)).to be false
      end
    end

    context 'when the user is an admin' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: subject, role: Team::ADMIN) }

      subject { user }

      it 'returns true' do
        expect(subject.admin_for?(site)).to be true
      end
    end

    context 'when the user is the owner' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: subject, role: Team::OWNER) }

      subject { user }

      it 'returns false' do
        expect(subject.admin_for?(site)).to be false
      end
    end
  end

  describe '#member_of?' do
    context 'when the user is not a member of the team' do
      let(:user) { create_user }
      let(:site) { create_site }

      subject { user }

      it 'returns false' do
        expect(subject.member_of?(site)).to be false
      end
    end

    context 'when the user is a member of the team' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: subject) }

      subject { user }

      it 'returns true' do
        expect(subject.member_of?(site)).to be true
      end
    end
  end

  describe '#serialize' do
    let(:user) { create_user }

    it 'serialized the user for the front end' do
      expect(user.serialize).to eq(
        'id' => user.id,
        'firstName' => user.first_name,
        'lastName' => user.last_name,
        'email' => user.email,
        'createdAt' => user.created_at,
        'updatedAt' => user.updated_at
      )
    end
  end

  describe '#invite_to_team!' do
    let(:user) { create_user }

    subject { user.invite_to_team! }

    before { allow(user).to receive(:generate_invitation_token!) }

    it 'calls the protected generate_invitation_token! method' do
      subject
      expect(user).to have_received(:generate_invitation_token!)
    end
  end

  describe '#pending_team_invitation?' do
    context 'when the user has no pending invitations' do
      let(:user) { create_user }

      it 'returns false' do
        expect(user.pending_team_invitation?).to be false
      end
    end

    context 'when the user has a pending invitation' do
      let(:user) { create_user }

      before { create_site_and_team(user: user, status: Team::PENDING) }

      it 'returns true' do
        expect(user.pending_team_invitation?).to be true
      end
    end
  end

  describe '.find_team_invitation' do
    context 'when the token does not match a user' do
      let(:token) { Faker::String.random }

      subject { User.find_team_invitation(token) }

      it 'returns the no email and status' do
        expect(subject).to eq(email: nil, has_pending: false)
      end
    end

    context 'when the user has an invitation token but no pending invites' do
      let(:user) { create_user }

      subject do
        user.invite_to_team!
        User.find_team_invitation(user.reload.raw_invitation_token)
      end

      it 'returns the the email and status' do
        expect(subject).to eq(email: user.email, has_pending: false)
      end
    end

    context 'when the user has an invitation and pending invites' do
      let(:user) { create_user }

      before { create_site_and_team(user: user, status: Team::PENDING) }

      subject do
        user.invite_to_team!
        User.find_team_invitation(user.reload.raw_invitation_token)
      end

      it 'returns the the email and status' do
        expect(subject).to eq(email: user.email, has_pending: true)
      end
    end
  end
end
