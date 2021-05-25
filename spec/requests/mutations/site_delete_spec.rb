# frozen_string_literal: true

require 'rails_helper'

site_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!) {
    siteDelete(input: { siteId: $site_id }) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::SiteDelete, type: :request do
  context 'when the user is not the owner' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: create_user) }
    let(:team) { create_team(user: user, site: site, role: Team::ADMIN) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_delete_mutation, variables, user)
    end

    before do
      team
      allow_any_instance_of(Site).to receive(:delete_authorizer!)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Forbidden'
    end

    it 'does not delete the site' do
      expect(site.reload).not_to be nil
    end

    it 'does not change the size of the team' do
      expect { subject }.not_to change { site.team.size }
    end
  end

  context 'when the user is the owner' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_delete_mutation, variables, user)
    end

    before do
      create_team(user: create_user, site: site, role: Team::MEMBER)
      create_team(user: create_user, site: site, role: Team::MEMBER)
      create_team(user: create_user, site: site, role: Team::MEMBER)

      site.reload
    end

    it 'returns nil' do
      expect(subject['data']['siteDelete']).to be nil
    end

    it 'deletes the site' do
      subject
      expect { site.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'deletes the team members' do
      expect { subject }.to change { Team.where(site_id: site.id).size }.from(4).to(0)
    end

    it 'deletes the authorizer' do
      expect_any_instance_of(Site).to receive(:delete_authorizer!)
      subject
    end
  end
end
