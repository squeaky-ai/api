# typed: false
# frozen_string_literal: true

require 'rails_helper'

sites_provider_auth_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      id
      providerAuth {
        provider
        providerUuid
        authType
        apiEndpoint
        providerAppUuid
      }
    }
  }
GRAPHQL

RSpec.describe 'SitesProviderAuth', type: :request do
  context 'when the site has no provider auth' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    it 'returns nil' do
      response = graphql_request(sites_provider_auth_query, { site_id: site.id }, user)

      expect(response['data']['site']['providerAuth']).to eq nil
    end
  end

  context 'when the site has provider auth' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let!(:auth) { create(:provider_auth, site:, provider: 'duda', provider_uuid: SecureRandom.uuid, auth_type: 'bearer') }

    before do
      ENV['DUDA_APP_UUID'] = SecureRandom.uuid
    end

    it 'returns the auth' do
      response = graphql_request(sites_provider_auth_query, { site_id: site.id }, user)

      expect(response['data']['site']['providerAuth']).to eq(
        'apiEndpoint' => nil,
        'authType' => 'bearer',
        'provider' => 'duda',
        'providerAppUuid' => ENV['DUDA_APP_UUID'],
        'providerUuid' => auth.provider_uuid
      )
    end
  end
end
