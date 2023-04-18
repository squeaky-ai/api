# frozen_string_literal: true

require 'rails_helper'

site_ip_blacklist_create_mutation = <<-GRAPHQL
  mutation($input: SitesIpBlacklistCreateInput!) {
    ipBlacklistCreate(input: $input) {
      id
      ipBlacklist {
        name
        value
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::IpBlacklistCreate, type: :request do
  context 'when adding a new ip' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          name: 'Test', 
          value: '0.0.0.0' 
        }
      }
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
