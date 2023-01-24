# frozen_string_literal: true

require 'rails_helper'

site_api_key_create_mutation = <<-GRAPHQL
  mutation($input: SitesApiKeyCreateInput!) {
    apiKeyCreate(input: $input) {
      id
      apiKey
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::ApiKeyCreate, type: :request do
  context 'when adding a new api key' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      allow(SecureRandom).to receive(:uuid).and_return('api_key')
    end

    subject do
      variables = { 
        input: {
          siteId: site.id
        }
      }
      graphql_request(site_api_key_create_mutation, variables, user)
    end

    it 'returns the updated site' do
      expect(subject['data']['apiKeyCreate']['apiKey']).to eq('api_key')
    end

    it 'updates the record' do
      expect { subject }.to change { site.reload.api_key }.from(nil).to('api_key')
    end
  end

  context 'when an api key already exists' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user, api_key: 'old_api_key') }

    before do
      allow(SecureRandom).to receive(:uuid).and_return('new_api_key')
    end

    subject do
      variables = { 
        input: {
          siteId: site.id
        }
      }
      graphql_request(site_api_key_create_mutation, variables, user)
    end

    it 'returns the updated site' do
      expect(subject['data']['apiKeyCreate']['apiKey']).to eq('new_api_key')
    end

    it 'updates the record' do
      expect { subject }.to change { site.reload.api_key }.from('old_api_key').to('new_api_key')
    end
  end
end
