# frozen_string_literal: true

require 'rails_helper'

team_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $team_id: ID!) {
    teamDelete(input: { siteId: $site_id, teamId: $team_id }) {
      team {
        id
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::TeamDelete, type: :request do
  context 'when the team member is the owner' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: create_user) }
    let(:team) { create_team(user: user, site: site, role: Team::ADMIN) }
    let(:subject) { graphql_request(team_delete_mutation, { site_id: site.id, team_id: site.owner.id }, user) }

    before { team }

    it 'returns the unmodified team' do
      expect(subject['data']['teamDelete']['team']).to eq [
        {
          'id' => site.owner.id.to_s
        },
        {
          'id' => team.id.to_s
        }
      ]
    end

    it 'does not remove the team member' do
      expect { subject }.not_to change { site.team.size }
    end
  end

  context 'when the team member is themselves' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: create_user) }
    let(:team) { create_team(user: user, site: site, role: Team::ADMIN) }
    let(:subject) { graphql_request(team_delete_mutation, { site_id: site.id, team_id: team.id }, user) }

    before { team }

    it 'returns the unmodified team' do
      expect(subject['data']['teamDelete']['team']).to eq [
        {
          'id' => site.owner.id.to_s
        },
        {
          'id' => team.id.to_s
        }
      ]
    end

    it 'does not remove the team member' do
      expect { subject }.not_to change { site.team.size }
    end
  end

  context 'when the team member can be deleted' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:team) { create_team(user: create_user, site: site, role: Team::ADMIN) }
    let(:subject) { graphql_request(team_delete_mutation, { site_id: site.id, team_id: team.id }, user) }

    before do
      team
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:member_removed).and_return(stub)
    end

    it 'returns the updated team' do
      expect(subject['data']['teamDelete']['team']).to eq [
        {
          'id' => site.owner.id.to_s
        }
      ]
    end

    it 'does not remove the team member' do
      expect { subject }.to change { site.team.size }.from(2).to(1)
    end

    it 'sends an email to the removed user' do
      subject
      expect(TeamMailer).to have_received(:member_removed).with(team.user.email, site)
    end
  end
end
