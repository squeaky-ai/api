# frozen_string_literal: true

require 'rails_helper'

team_update_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $team_id: ID!, $role: Int!) {
    teamUpdate(input: { siteId: $site_id, teamId: $team_id, role: $role }) {
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

RSpec.describe Mutations::TeamUpdate, type: :request do
  context 'when the team member does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user) }
    let(:subject) { graphql_request(team_update_mutation, { site_id: site.id, team_id: 4324, role: 1 }, user) }

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Team member not found'
    end
  end

  context 'when the role is not valid' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user) }
    let(:team) { create_team(user: create_user, site: site, role: 0, status: 0) }
    let(:subject) { graphql_request(team_update_mutation, { site_id: site.id, team_id: team.id, role: 5 }, user) }

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Team role is invalid'
    end
  end

  context 'when trying to modify the owner of the site' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user) }

    let(:subject) do
      graphql_request(team_update_mutation, { site_id: site.id, team_id: site.team[0].id, role: 1 }, user)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Forbidden'
    end
  end

  context 'when the user is made an admin' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user) }
    let(:team) { create_team(user: create_user, site: site, role: 0, status: 0) }
    let(:subject) { graphql_request(team_update_mutation, { site_id: site.id, team_id: team.id, role: 1 }, user) }

    before do
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:became_admin).and_return(stub)
    end

    it 'returns the updated user' do
      response = subject['data']['teamUpdate']
      team_member = response['team'].find { |t| t['id'] == team.id.to_s }
      expect(team_member['role']).to eq 1
    end

    it 'sends an email' do
      subject
      expect(TeamMailer).to have_received(:became_admin).with(team.user.email, site, user)
    end
  end

  context 'when the user is made a member' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user) }
    let(:team) { create_team(user: create_user, site: site, role: 1, status: 0) }
    let(:subject) { graphql_request(team_update_mutation, { site_id: site.id, team_id: team.id, role: 0 }, user) }

    before do
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:became_admin).and_return(stub)
    end

    it 'returns the updated user' do
      response = subject['data']['teamUpdate']
      team_member = response['team'].find { |t| t['id'] == team.id.to_s }
      expect(team_member['role']).to eq 0
    end

    it 'does not send an email' do
      subject
      expect(TeamMailer).not_to have_received(:became_admin)
    end
  end
end
