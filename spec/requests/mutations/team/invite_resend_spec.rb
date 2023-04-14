# typed: false
# frozen_string_literal: true

require 'rails_helper'

team_invite_resend_mutation = <<-GRAPHQL
  mutation($input: TeamInviteResendInput!) {
    teamInviteResend(input: $input) {
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

RSpec.describe Mutations::Teams::InviteResend, type: :request do
  context 'when the team member does not exist' do
    let(:user) { create(:user) }
    let!(:site) { create(:site_with_team, owner: user) }
    let(:team_id) { 234 }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: team_id 
        }
      }
      graphql_request(team_invite_resend_mutation, variables, user)
    end

    it 'returns nil' do
      team = subject['data']['teamInviteResend']
      expect(team).to be_nil
    end

    it 'does not send the email' do
      expect { subject }.not_to change { ActionMailer::Base.deliveries.size }
    end
  end

  context 'when the team member exists but is not pending' do
    let(:user) { create(:user) }
    let!(:site) { create(:site_with_team, owner: user) }
    let!(:team_member) { create(:team, site: site, role: Team::ADMIN, status: Team::ACCEPTED) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: team_member.id 
        }
      }
      graphql_request(team_invite_resend_mutation, variables, user)
    end

    before do
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:invite).and_return(stub)
    end

    it 'returns the team' do
      team = subject['data']['teamInviteResend']
      expect(team).not_to be nil
    end

    it 'does not send the email' do
      expect { subject }.not_to change { ActionMailer::Base.deliveries.size }
    end
  end

  context 'when the team member exist and is pending' do
    let(:user) { create(:user) }
    let!(:site) { create(:site_with_team, owner: user) }
    let!(:team_member) { create(:team, site: site, role: Team::ADMIN, status: Team::PENDING) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: team_member.id
        }
      }
      graphql_request(team_invite_resend_mutation, variables, user)
    end

    it 'returns the team' do
      team = subject['data']['teamInviteResend']
      expect(team).not_to be nil
    end

    it 'does sends the email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
