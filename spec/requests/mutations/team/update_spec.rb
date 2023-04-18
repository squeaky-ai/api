# frozen_string_literal: true

require 'rails_helper'

team_update_mutation = <<-GRAPHQL
  mutation($input: TeamUpdateInput!) {
    teamUpdate(input: $input) {
      id
      linkedDataVisible
    }
  }
GRAPHQL

RSpec.describe Mutations::Teams::Update, type: :request do
  context 'when the team member does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: 4324,
          linkedDataVisible: true
        }
      }
      graphql_request(team_update_mutation, variables, user)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Team member not found'
    end
  end

  context 'when a member tries to make a change' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    
    let(:team) { create(:team, site:, role: Team::MEMBER) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: 4324,
          linkedDataVisible: true
        }
      }
      graphql_request(team_update_mutation, variables, team.user)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'You lack the required permissions to do this'
    end
  end

  context 'when an admin tries to modify an owner' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    
    let(:team) { create(:team, site:, role: Team::MEMBER) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: user.id,
          linkedDataVisible: true
        }
      }
      graphql_request(team_update_mutation, variables, team.user)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'You lack the required permissions to do this'
    end
  end

  context 'when the user can make the change' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    
    let(:team) { create(:team, site:, role: Team::MEMBER, linked_data_visible: false) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          teamId: team.id,
          linkedDataVisible: true
        }
      }
      graphql_request(team_update_mutation, variables, user)
    end

    it 'updates the team' do
      expect { subject }.to change { team.reload.linked_data_visible }.from(false).to(true)
    end

    it 'returns the new value' do
      response = subject['data']['teamUpdate']
      expect(response['linkedDataVisible']).to eq(true)
    end
  end
end
