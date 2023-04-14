# typed: false
# frozen_string_literal: true

require 'rails_helper'

team_update_role_mutation = <<-GRAPHQL
  mutation($input: TeamUpdateRoleInput!) {
    teamUpdateRole(input: $input) {
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

RSpec.describe Mutations::Teams::UpdateRole, type: :request do
  context 'when the team member does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: 4324,
          role: Team::ADMIN 
        }
      }
      graphql_request(team_update_role_mutation, variables, user)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Team member not found'
    end
  end

  context 'when the role is not valid' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:team) { create(:team, site: site, role: Team::MEMBER, status: Team::ACCEPTED) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: team.id, 
          role: 5 
        }
      }
      graphql_request(team_update_role_mutation, variables, user)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Team role is invalid'
    end
  end

  context 'when trying to modify the owner of the site' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          teamId: site.team[0].id, 
          role: Team::ADMIN 
        }
      }
      graphql_request(team_update_role_mutation, variables, user)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Forbidden'
    end
  end

  context 'when the user is made an admin' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:team) { create(:team, site: site, role: Team::MEMBER, status: Team::ACCEPTED) }

    subject do
      variables = { 
        input: {
          siteId: site.id,
          teamId: team.id, 
          role: Team::ADMIN 
        }
      }
      graphql_request(team_update_role_mutation, variables, user)
    end

    before do
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:became_admin).and_return(stub)
    end

    it 'returns the updated team' do
      team = subject['data']['teamUpdateRole']
      expect(team['role']).to eq 1
    end

    it 'sends an email' do
      subject
      expect(TeamMailer).to have_received(:became_admin).with(team.user.email, site, user)
    end
  end

  context 'when the user is made a member' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:team) { create(:team, site: site, role: Team::ADMIN, status: Team::ACCEPTED) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: team.id, 
          role: Team::MEMBER 
        }
      }
      graphql_request(team_update_role_mutation, variables, user)
    end

    before do
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:became_admin).and_return(stub)
    end

    it 'returns the updated user' do
      team = subject['data']['teamUpdateRole']
      expect(team['role']).to eq 0
    end

    it 'does not send an email' do
      subject
      expect(TeamMailer).not_to have_received(:became_admin)
    end
  end

  context 'when an admin promotes a member' do
    let(:site) { create(:site_with_team) }

    let(:team1) { create(:team, site: site, role: Team::ADMIN) }
    let(:team2) { create(:team, site: site, role: Team::MEMBER) }

    before do
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:became_admin).and_return(stub)
    end

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: team2.id, 
          role: Team::ADMIN 
        }
      }
      graphql_request(team_update_role_mutation, variables, team1.user)
    end

    it 'returns the updated user' do
      team = subject['data']['teamUpdateRole']
      expect(team['role']).to eq 1
    end

    it 'sends an email' do
      subject
      expect(TeamMailer).to have_received(:became_admin).with(team2.user.email, site, team1.user)
    end
  end

  context 'when an admin tries to downgrade another admin' do
    let(:site) { create(:site_with_team) }

    let(:team1) { create(:team, site: site, role: Team::ADMIN) }
    let(:team2) { create(:team, site: site, role: Team::ADMIN) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: team2.id, 
          role: Team::MEMBER 
        }
      }
      graphql_request(team_update_role_mutation, variables, team1.user)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Forbidden'
    end

    it 'does not modify the role' do
      expect { subject }.not_to change { Team.find(team2.id).role }
    end
  end
end
