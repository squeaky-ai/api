# frozen_string_literal: true

require 'rails_helper'

site_ip_blacklist_create_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $name: String!, $value: String!) {
    ipBlacklistCreate(input: { siteId: $site_id, name: $name, value: $value }) {
      id
      ipBlacklist {
        name
        value
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::SiteIpBlacklistCreate, type: :request do
  context 'when creating a brand new tag' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, name: 'Test', value: '0.0.0.0' }
      graphql_request(site_ip_blacklist_create_mutation, variables, user)
    end

    it 'returns the updated site' do
      expect(subject['data']['ipBlacklistCreate']['ipBlacklist']).to eq(
        [
          {
            'name' => 'Test',
            'value' => '0.0.0.0'
          }
        ]  
      )
    end

    it 'updates the record' do
      expect { subject }.to change { site.reload.ip_blacklist.size }.from(0).to(1)
    end
  end
end
