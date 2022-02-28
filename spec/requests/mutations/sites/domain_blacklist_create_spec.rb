# frozen_string_literal: true

require 'rails_helper'

site_domain_blacklist_create_mutation = <<-GRAPHQL
  mutation($input: SitesDomainBlacklistCreateInput!) {
    domainBlacklistCreate(input: $input) {
      id
      domainBlacklist {
        type
        value
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::DomainBlacklistCreate, type: :request do
  context 'when creating a new domain' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          type: 'domain', 
          value: 'squeaky.ai'
        }
      }
      graphql_request(site_domain_blacklist_create_mutation, variables, user)
    end

    it 'returns the updated site' do
      expect(subject['data']['domainBlacklistCreate']['domainBlacklist']).to eq(
        [
          {
            'type' => 'domain',
            'value' => 'squeaky.ai'
          }
        ]  
      )
    end

    it 'updates the record' do
      expect { subject }.to change { site.reload.domain_blacklist.size }.from(0).to(1)
    end
  end

  context 'when creating a new email' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          type: 'email', 
          value: 'john@squeaky.ai' 
        }
      }
      graphql_request(site_domain_blacklist_create_mutation, variables, user)
    end

    it 'returns the updated site' do
      expect(subject['data']['domainBlacklistCreate']['domainBlacklist']).to eq(
        [
          {
            'type' => 'email',
            'value' => 'john@squeaky.ai'
          }
        ]  
      )
    end

    it 'updates the record' do
      expect { subject }.to change { site.reload.domain_blacklist.size }.from(0).to(1)
    end
  end

  context 'when some visitors exist and some have matching domains' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, site: site, visitor: create(:visitor, external_attributes: { email: 'jim@squeaky.ai' }))
      create(:recording, site: site, visitor: create(:visitor, external_attributes: { email: 'ray@squeaky.ai' }))
      create(:recording, site: site, visitor: create(:visitor, external_attributes: { email: 'john@squeaky.ai' }))
      create(:recording, site: site, visitor: create(:visitor, external_attributes: { email: 'robby@squeaky.ai' }))
      create(:recording, site: site, visitor: create(:visitor, external_attributes: { email: 'asd@asdas.ai' }))
    end

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          type: 'domain', 
          value: 'squeaky.ai' 
        }
      }
      graphql_request(site_domain_blacklist_create_mutation, variables, user)
    end

    it 'updates the record' do
      expect { subject }.to change { site.reload.domain_blacklist.size }.from(0).to(1)
    end

    it 'deletes recordings that match the attributes' do
      expect { subject }.to change { site.reload.recordings.size }.from(5).to(1)
    end

    it 'deletes visitors that match the attributes' do
      expect { subject }.to change { site.reload.visitors.size }.from(5).to(1)
    end
  end
  
  context 'when some visitors exist and some have matching emails' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, site: site, visitor: create(:visitor, external_attributes: { email: 'jim@squeaky.ai' }))
      create(:recording, site: site, visitor: create(:visitor, external_attributes: { email: 'ray@squeaky.ai' }))
      create(:recording, site: site, visitor: create(:visitor, external_attributes: { email: 'john@squeaky.ai' }))
      create(:recording, site: site, visitor: create(:visitor, external_attributes: { email: 'robby@squeaky.ai' }))
      create(:recording, site: site, visitor: create(:visitor, external_attributes: { email: 'asd@asdas.ai' }))
    end

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          type: 'email', 
          value: 'john@squeaky.ai' 
        }
      }
      graphql_request(site_domain_blacklist_create_mutation, variables, user)
    end

    it 'updates the record' do
      expect { subject }.to change { site.reload.domain_blacklist.size }.from(0).to(1)
    end

    it 'deletes recordings that match the attributes' do
      expect { subject }.to change { site.reload.recordings.size }.from(5).to(4)
    end

    it 'deletes visitors that match the attributes' do
      expect { subject }.to change { site.reload.visitors.size }.from(5).to(4)
    end
  end
end
