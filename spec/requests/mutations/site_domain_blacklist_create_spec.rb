# frozen_string_literal: true

require 'rails_helper'

site_domain_blacklist_create_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $type: String!, $value: String!) {
    domainBlacklistCreate(input: { siteId: $site_id, type: $type, value: $value }) {
      id
      domainBlacklist {
        type
        value
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::SiteDomainBlacklistCreate, type: :request do
  context 'when creating a brand new tag' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, type: 'domain', value: '@squeaky.ai' }
      graphql_request(site_domain_blacklist_create_mutation, variables, user)
    end

    it 'returns the updated site' do
      expect(subject['data']['domainBlacklistCreate']['domainBlacklist']).to eq(
        [
          {
            'type' => 'domain',
            'value' => '@squeaky.ai'
          }
        ]  
      )
    end

    it 'updates the record' do
      expect { subject }.to change { site.reload.domain_blacklist.size }.from(0).to(1)
    end
  end
end
