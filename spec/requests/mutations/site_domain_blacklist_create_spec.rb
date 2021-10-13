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
  context 'when creating a new domain' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, type: 'domain', value: 'squeaky.ai' }
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
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, type: 'email', value: 'john@squeaky.ai' }
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
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      allow(SearchClient).to receive(:bulk)

      create_recording(site: site, visitor: create_visitor(external_attributes: { email: 'jim@squeaky.ai' }))
      create_recording(site: site, visitor: create_visitor(external_attributes: { email: 'ray@squeaky.ai' }))
      create_recording(site: site, visitor: create_visitor(external_attributes: { email: 'john@squeaky.ai' }))
      create_recording(site: site, visitor: create_visitor(external_attributes: { email: 'robby@squeaky.ai' }))
      create_recording(site: site, visitor: create_visitor(external_attributes: { email: 'asd@asdas.ai' }))
    end

    subject do
      variables = { site_id: site.id, type: 'domain', value: 'squeaky.ai' }
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

    it 'should delete the items from ES' do
      subject
      expect(SearchClient).to have_received(:bulk)
    end
  end
  
  context 'when some visitors exist and some have matching emails' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      allow(SearchClient).to receive(:bulk)

      create_recording(site: site, visitor: create_visitor(external_attributes: { email: 'jim@squeaky.ai' }))
      create_recording(site: site, visitor: create_visitor(external_attributes: { email: 'ray@squeaky.ai' }))
      create_recording(site: site, visitor: create_visitor(external_attributes: { email: 'john@squeaky.ai' }))
      create_recording(site: site, visitor: create_visitor(external_attributes: { email: 'robby@squeaky.ai' }))
      create_recording(site: site, visitor: create_visitor(external_attributes: { email: 'asd@asdas.ai' }))
    end

    subject do
      variables = { site_id: site.id, type: 'email', value: 'john@squeaky.ai' }
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

    it 'should delete the items from ES' do
      subject
      expect(SearchClient).to have_received(:bulk)
    end
  end
end
