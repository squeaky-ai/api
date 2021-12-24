# frozen_string_literal: true

require 'rails_helper'

team_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $team_id: ID!) {
    teamDelete(input: { siteId: $site_id, teamId: $team_id }) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Teams::Delete, type: :request do
  context 'when the team member is the owner' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team) }
    let(:team) { create(:team, user: user, site: site, role: Team::ADMIN) }

    subject do
      variables = { site_id: site.id, team_id: site.owner.id }
      graphql_request(team_delete_mutation, variables, user)
    end

    before { team }

    it 'returns the unmodified team' do
      expect(subject['data']['teamDelete']).to eq('id' => site.owner.id.to_s)
    end

    it 'does not remove the team member' do
      expect { subject }.not_to change { site.team.size }
    end
  end

  context 'when the team member is themselves' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team) }
    let(:team) { create(:team, user: user, site: site, role: Team::ADMIN) }

    subject do
      variables = { site_id: site.id, team_id: team.id }
      graphql_request(team_delete_mutation, variables, user)
    end

    before { team }

    it 'returns the unmodified team' do
      expect(subject['data']['teamDelete']).to eq('id' => team.id.to_s)
    end

    it 'does not remove the team member' do
      expect { subject }.not_to change { site.team.size }
    end
  end

  context 'when an admin tries to remove another admin' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team) }
    let(:team1) { create(:team, user: user, site: site, role: Team::ADMIN) }
    let(:team2) { create(:team, site: site, role: Team::ADMIN) }

    before do
      site
      team1
      team2
    end

    subject do
      variables = { site_id: site.id, team_id: team2.id }
      graphql_request(team_delete_mutation, variables, user)
    end

    it 'returns the unmodified team' do
      expect(subject['data']['teamDelete']).to eq('id' => team2.id.to_s)
    end

    it 'does not remove the team member' do
      expect { subject }.not_to change { site.team.size }
    end
  end

  context 'when the team member can be deleted' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:team) { create(:team, site: site, role: Team::MEMBER) }

    subject do
      variables = { site_id: site.id, team_id: team.id }
      graphql_request(team_delete_mutation, variables, user)
    end

    before do
      team
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:member_removed).and_return(stub)
    end

    it 'returns nil' do
      expect(subject['data']['teamDelete']).to eq nil
    end

    it 'does removes the team member' do
      expect { subject }.to change { site.team.size }.from(2).to(1)
    end

    it 'sends an email to the removed user' do
      subject
      expect(TeamMailer).to have_received(:member_removed).with(team.user.email, site)
    end
  end
end
