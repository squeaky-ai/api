# typed: false
# frozen_string_literal: true

require 'rails_helper'

team_invite_accept_mutation = <<-GRAPHQL
  mutation($input: TeamInviteAcceptInput!) {
    teamInviteAccept(input: $input) {
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

RSpec.describe Mutations::Teams::InviteAccept, type: :request do
  context 'when the token is not valid' do
    let(:token) { 'sdfdsfdsfdsf' }

    before do
      allow(OnboardingMailerService).to receive(:enqueue)
    end

    subject do
      variables = { 
        input: {
          token:, 
          password: 'dfgdfgdfg' 
        }
      }
      graphql_request(team_invite_accept_mutation, variables, nil)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Team invite is invalid'
    end

    it 'does not enqueue the onboarding emails' do
      subject
      expect(OnboardingMailerService).not_to have_received(:enqueue)
    end
  end

  context 'when the token is valid, but has been cancelled' do
    let(:site) { create(:site) }
    let(:user) { invite_user } # The team won't exist

    before do
      allow(OnboardingMailerService).to receive(:enqueue)
    end

    subject do
      variables = { 
        input: {
          token: user.raw_invitation_token, 
          password: 'sdfsfdsf' 
        }
      }
      graphql_request(team_invite_accept_mutation, variables, nil)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Team invite has expired'
    end

    it 'does not enqueue the onboarding emails' do
      subject
      expect(OnboardingMailerService).not_to have_received(:enqueue)
    end
  end

  context 'when the token is valid' do
    context 'when it is a new user' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let!(:team) { create(:team, user: invite_user, site: site, role: Team::ADMIN, status: Team::PENDING) }

      before do
        allow(OnboardingMailerService).to receive(:enqueue)
      end

      subject do
        variables = { 
          input: {
            token: team.user.raw_invitation_token, 
            password: 'sdfsdfsdf' 
          }
        }
        graphql_request(team_invite_accept_mutation, variables, nil)
      end

      it 'sets the team status as accepted' do
        expect { subject }.to change { Team.find(team.id).pending? }.from(true).to(false)
      end

      it 'updates the password' do
        expect { subject }.to change { User.find(team.user.id).encrypted_password }
      end

      it 'does not send any emails' do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.size }
      end

      it 'enqueues the onboarding emails' do
        subject
        expect(OnboardingMailerService).to have_received(:enqueue)
      end
    end

    context 'when it is an existing user' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let!(:team) { create(:team, site: site, role: Team::ADMIN, status: Team::PENDING) }

      before do
        allow(OnboardingMailerService).to receive(:enqueue)
      end

      subject do
        team.user.invite_to_team!
        variables = { 
          input: {
            token: team.user.reload.raw_invitation_token 
          }
        }
        graphql_request(team_invite_accept_mutation, variables, nil)
      end

      it 'sets the team status as accepted' do
        expect { subject }.to change { Team.find(team.id).pending? }.from(true).to(false)
      end

      it 'does not update the password' do
        expect { subject }.not_to change { User.find(team.user.id).encrypted_password }
      end

      it 'does not send any emails' do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.size }
      end

      it 'does not enqueue the onboarding emails' do
        subject
        expect(OnboardingMailerService).not_to have_received(:enqueue)
      end
    end
  end
end
