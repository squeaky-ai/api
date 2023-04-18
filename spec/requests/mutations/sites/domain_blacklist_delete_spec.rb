# frozen_string_literal: true

require 'rails_helper'

site_domain_blacklist_delete_mutation = <<-GRAPHQL
  mutation($input: SitesDomainBlacklistDeleteInput!) {
    domainBlacklistDelete(input: $input) {
      id
      domainBlacklist {
        type
        value
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::DomainBlacklistDelete, type: :request do
  context 'when deleting a tag that does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          value: '@squeaky.ai' 
        }
      }
      graphql_request(site_domain_blacklist_delete_mutation, variables, user)
    end

    it 'returns the original site' do
      expect(subject['data']['domainBlacklistDelete']['domainBlacklist']).to eq([])
    end

    it 'does not update the record' do
      expect { subject }.not_to change { site.reload.ip_blacklist.size }
    end
  end

  context 'when deleting a tag that does exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      site.domain_blacklist << { type: 'domain', value: '@squeaky.ai' }
      site.save
    end

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          value: '@squeaky.ai' 
        }
      }
      graphql_request(site_domain_blacklist_delete_mutation, variables, user)
    end

    it 'returns the updated site' do
      expect(subject['data']['domainBlacklistDelete']['domainBlacklist']).to eq([])
    end

    it 'updates the record' do
      expect { subject }.to change { site.reload.domain_blacklist.size }.from(1).to(0)
    end
  end
end
