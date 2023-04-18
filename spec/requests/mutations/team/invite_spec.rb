# typed: false
# frozen_string_literal: true

require 'rails_helper'

team_invite_mutation = <<-GRAPHQL
  mutation($input: TeamInviteInput!) {
    teamInvite(input: $input) {
      id
      role
      status
      user {
        id
        firstName
        lastName
        email
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Teams::Invite, type: :request do
  context 'when the invited user does not have an account' do
    let(:user) { create(:user) }
    let!(:site) { create(:site_with_team, owner: user) }
    let(:email) { 'paulmccartney@msn.com' }

    subject do
      variables = { 
        input: {
          siteId: site.id,
          email:, 
          role: Team::ADMIN 
        }
      }
      graphql_request(team_invite_mutation, variables, user)
    end

    it 'returns the team' do
      team = subject['data']['teamInvite']
      expect(team).not_to be nil
    end

    it 'creates them an account' do
      subject
      invited_user = User.find_by(email: email)
      expect(invited_user).not_to be nil
      expect(invited_user.invitation_sent_at).not_to be nil
    end

    it 'sends an invite request to the email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end

  context 'when the user alredy has an account' do
    context 'and they are already a member' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let(:invited_user) { create(:user) }

      subject do
        variables = { 
          input: {
            siteId: site.id, 
            email: invited_user.email, 
            role: Team::ADMIN 
          }
        }
        graphql_request(team_invite_mutation, variables, user)
      end

      before do
        create(:team, user: invited_user, site: site, role: Team::ADMIN)
      end

      it 'returns an error' do
        expect(subject['errors'][0]['message']).to eq 'Team member already exists'
      end

      it 'does not add them a second time' do
        expect { subject }.not_to change { site.team.size }
      end

      it 'does not send an email' do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.size }
      end
    end

    context 'and they are not a member' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let(:invited_user) { create(:user) }

      before do
        stub = double
        allow(stub).to receive(:deliver_now)
        allow(AuthMailer).to receive(:invitation_instructions).and_return(stub)
      end

      subject do
        variables = { 
          input: {
            siteId: site.id, 
            email: invited_user.email,
            role: Team::ADMIN
          }
        }

        graphql_request(team_invite_mutation, variables, user)
      end

      it 'returns the team' do
        team = subject['data']['teamInvite']
        expect(team).not_to be nil
      end

      it 'adds them to the team' do
        expect { subject }.to change { site.team.size }.from(1).to(2)
      end

      it 'does not change the users password' do
        expect { subject }.not_to change { User.find(invited_user.id).encrypted_password }
      end

      it 'sends the email' do
        subject
        expect(AuthMailer).to have_received(:invitation_instructions)
      end
    end
  end
end
