# frozen_string_literal: true

require 'rails_helper'

team_invite_resend_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $team_id: ID!) {
    teamInviteResend(input: { siteId: $site_id, teamId: $team_id }) {
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
    let(:site) { create(:site_with_team, owner: user) }
    let(:team_id) { 234 }

    before { site }

    subject do
      variables = { site_id: site.id, team_id: team_id }
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
    let(:site) { create(:site_with_team, owner: user) }
    let(:team_member) { create(:team, site: site, role: Team::ADMIN, status: Team::ACCEPTED) }

    before do
      site
      team_member
    end

    subject do
      variables = { site_id: site.id, team_id: team_member.id }
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
    let(:site) { create(:site_with_team, owner: user) }
    let(:team_member) { create(:team, site: site, role: Team::ADMIN, status: Team::PENDING) }

    before do
      site
      team_member
    end

    subject do
      variables = { site_id: site.id, team_id: team_member.id }
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
