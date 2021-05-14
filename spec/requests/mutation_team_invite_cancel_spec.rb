# frozen_string_literal: true

require 'rails_helper'

team_invite_cancel_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $team_id: ID!) {
    teamInviteCancel(input: { siteId: $site_id, teamId: $team_id }) {
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

RSpec.describe Mutations::TeamInviteCancel, type: :request do
  context 'when the team member does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user) }
    let(:team_id) { 234 }
    let(:subject) { graphql_request(team_invite_cancel_mutation, { site_id: site.id, team_id: team_id }, user) }

    it 'returns the site and team without the team id' do
      team = subject['data']['teamInviteCancel']['team']
      invited_team_member = team.find { |t| t['id'].to_i == team_id }
      expect(invited_team_member).to be_nil
    end

    it 'does not change the team count' do
      expect { subject }.not_to change { site.team.size }
    end
  end

  context 'when the team member exist but is not pending' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user) }
    let(:team_member) { create_team(user: create_user, site: site, role: 1, status: 0) }
    let(:subject) { graphql_request(team_invite_cancel_mutation, { site_id: site.id, team_id: team_member.id }, user) }

    before { team_member } # Otherwise subject will be responsible for creating the team

    it 'returns the site with the existing team' do
      team = subject['data']['teamInviteCancel']['team']
      member = team.find { |t| t['id'].to_i == team_member.id }
      expect(member).not_to be nil
    end

    it 'does not change the team count' do
      expect { subject }.not_to change { site.team.size }
    end
  end

  context 'when the team member exist and is pending' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user) }
    let(:team_member) { create_team(user: create_user, site: site, role: 1, status: 1) }
    let(:subject) { graphql_request(team_invite_cancel_mutation, { site_id: site.id, team_id: team_member.id }, user) }

    before { team_member }

    it 'returns the site without the team member' do
      team = subject['data']['teamInviteCancel']['team']
      member = team.find { |t| t['id'].to_i == team_member.id }
      expect(member).to be nil
    end

    it 'does changes the team count' do
      expect { subject }.to change { site.team.size }.from(2).to(1)
    end
  end
end
