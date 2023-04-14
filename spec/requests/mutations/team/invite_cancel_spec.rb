# typed: false
# frozen_string_literal: true

require 'rails_helper'

team_invite_cancel_mutation = <<-GRAPHQL
  mutation($input: TeamInviteCancelInput!) {
    teamInviteCancel(input: $input) {
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

RSpec.describe Mutations::Teams::InviteCancel, type: :request do
  context 'when the team member does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:team_id) { 234 }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: team_id 
        }
      }
      graphql_request(team_invite_cancel_mutation, variables, user)
    end

    it 'returns nil' do
      team = subject['data']['teamInviteCancel']
      expect(team).to be_nil
    end

    it 'does not change the team count' do
      expect { subject }.not_to change { site.team.size }
    end
  end

  context 'when the team member exist but is not pending' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let!(:team_member) { create(:team, site: site, role: Team::ADMIN, status: Team::ACCEPTED) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: team_member.id 
        }
      }
      graphql_request(team_invite_cancel_mutation, variables, user)
    end

    it 'returns the team' do
      team = subject['data']['teamInviteCancel']
      expect(team).not_to be nil
    end

    it 'does not change the team count' do
      expect { subject }.not_to change { site.team.size }
    end
  end

  context 'when the team member exist and is pending' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let!(:team_member) { create(:team, site: site, role: Team::ADMIN, status: Team::PENDING) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: team_member.id 
        }
      }
      graphql_request(team_invite_cancel_mutation, variables, user)
    end

    it 'returns nil' do
      team = subject['data']['teamInviteCancel']
      expect(team).to be nil
    end

    it 'does changes the team count' do
      expect { subject }.to change { site.team.size }.from(2).to(1)
    end
  end
end
