# frozen_string_literal: true

require 'rails_helper'

team_invite_resend_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $team_id: ID!) {
    teamInviteResend(input: { siteId: $site_id, teamId: $team_id }) {
      team {
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
  }
GRAPHQL

RSpec.describe Mutations::TeamInviteResend, type: :request do
  context 'when the team member does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:team_id) { 234 }

    subject do
      variables = { site_id: site.id, team_id: team_id }
      graphql_request(team_invite_resend_mutation, variables, user)
    end

    before do
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:invite).and_return(stub)
    end

    it 'returns the site and team without the team id' do
      team = subject['data']['teamInviteResend']['team']
      invited_team_member = team.find { |t| t['id'].to_i == team_id }
      expect(invited_team_member).to be_nil
    end

    it 'does not send the email' do
      subject
      expect(TeamMailer).not_to have_received(:invite)
    end
  end

  context 'when the team member exists but is not pending' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:team_member) { create_team(user: create_user, site: site, role: Team::ADMIN, status: Team::ACCEPTED) }

    subject do
      variables = { site_id: site.id, team_id: team_member.id }
      graphql_request(team_invite_resend_mutation, variables, user)
    end

    before do
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:invite).and_return(stub)
    end

    it 'returns the site with the existing team' do
      team = subject['data']['teamInviteResend']['team']
      member = team.find { |t| t['id'].to_i == team_member.id }
      expect(member).not_to be nil
    end

    it 'does not send the email' do
      subject
      expect(TeamMailer).not_to have_received(:invite)
    end
  end

  context 'when the team member exist and is pending' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:team_member) { create_team(user: create_user, site: site, role: Team::ADMIN, status: Team::PENDING) }

    subject do
      variables = { site_id: site.id, team_id: team_member.id }
      graphql_request(team_invite_resend_mutation, variables, user)
    end

    before do
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:invite).and_return(stub)
      allow(JsonWebToken).to receive(:encode).and_return '__jwt__'
    end

    it 'returns the site with the existing team' do
      team = subject['data']['teamInviteResend']['team']
      member = team.find { |t| t['id'].to_i == team_member.id }
      expect(member).not_to be nil
    end

    it 'does not send the email' do
      subject
      expect(TeamMailer).to have_received(:invite).with(team_member.user.email, site, user, '__jwt__')
    end
  end
end
