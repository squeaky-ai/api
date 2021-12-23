# frozen_string_literal: true

require 'rails_helper'

team_transfer_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $team_id: ID!) {
    teamTransfer(input: { siteId: $site_id, teamId: $team_id }) {
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

RSpec.describe Mutations::Teams::Transfer, type: :request do
  context 'when the team member does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, team_id: 4234 }
      graphql_request(team_transfer_mutation, variables, user)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Team member not found'
    end
  end

  context 'when the user is not the owner of the site' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team) }
    let(:team) { create(:team, user: user, site: site, role: Team::ADMIN) }

    subject do
      variables = { site_id: site.id, team_id: team.id }
      graphql_request(team_transfer_mutation, variables, user)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'You lack the required permissions to do this'
    end
  end

  context 'when the user is the owner of the site' do
    let(:site) { create(:site) }

    let(:old_owner) { create(:user) }
    let(:old_owner_team) { create(:team, user: old_owner, site: site, role: Team::OWNER) }

    let(:new_owner) { create(:user) }
    let(:new_owner_team) { create(:team, user: new_owner, site: site, role: Team::ADMIN) }

    subject do
      graphql_request(team_transfer_mutation, { site_id: site.id, team_id: new_owner_team.id }, old_owner_team.user)
    end

    before do
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:became_owner).and_return(stub)
    end

    it 'returns the updated site' do
      expect(subject['data']['teamTransfer']['team']).to eq [
        {
          'id' => new_owner_team.id.to_s,
          'role' => Team::OWNER,
          'status' => Team::ACCEPTED,
          'user' => {
            'id' => new_owner.id.to_s,
            'firstName' => new_owner.first_name,
            'lastName' => new_owner.last_name,
            'email' => new_owner.email
          }
        },
        {
          'id' => old_owner_team.id.to_s,
          'role' => Team::ADMIN,
          'status' => Team::ACCEPTED,
          'user' => {
            'id' => old_owner.id.to_s,
            'firstName' => old_owner.first_name,
            'lastName' => old_owner.last_name,
            'email' => old_owner.email
          }
        }
      ]
    end

    it 'makes the old owner an admin' do
      expect { subject }.to change { old_owner_team.reload.role }.from(Team::OWNER).to(Team::ADMIN)
    end

    it 'makes the new owner the owner' do
      expect { subject }.to change { new_owner_team.reload.role }.from(Team::ADMIN).to(Team::OWNER)
    end

    it 'sends an email to the new owner' do
      subject
      expect(TeamMailer).to have_received(:became_owner).with(new_owner.email, site, old_owner)
    end
  end
end
