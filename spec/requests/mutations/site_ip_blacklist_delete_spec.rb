# frozen_string_literal: true

require 'rails_helper'

site_ip_blacklist_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $value: String!) {
    ipBlacklistDelete(input: { siteId: $site_id, value: $value }) {
      id
      ipBlacklist {
        name
        value
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::SiteIpBlacklistDelete, type: :request do
  context 'when deleting a tag that does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, value: '0.0.0.0' }
      graphql_request(site_ip_blacklist_delete_mutation, variables, user)
    end

    it 'returns the original site' do
      expect(subject['data']['ipBlacklistDelete']['ipBlacklist']).to eq([])
    end

    it 'does not update the record' do
      expect { subject }.not_to change { site.reload.ip_blacklist.size }
    end
  end

  context 'when deleting a tag that does exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      site.ip_blacklist << { name: 'Test', value: '0.0.0.0' }
      site.save
    end

    subject do
      variables = { site_id: site.id, value: '0.0.0.0' }
      graphql_request(site_ip_blacklist_delete_mutation, variables, user)
    end

    it 'returns the updated site' do
      expect(subject['data']['ipBlacklistDelete']['ipBlacklist']).to eq([])
    end

    it 'updates the record' do
      expect { subject }.to change { site.reload.ip_blacklist.size }.from(1).to(0)
    end
  end
end
