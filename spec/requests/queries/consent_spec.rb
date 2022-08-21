# frozen_string_literal: true

require 'rails_helper'

consent_query = <<-GRAPHQL
  query($site_id: String!) {
    consent(siteId: $site_id) {
      name
      consentMethod
      layout
      privacyPolicyUrl
      languages
      languagesDefault
    }
  }
GRAPHQL

RSpec.describe 'QueryConsent', type: :request do
  context 'when the site has no consent saved' do
    it 'does not return the consent' do
      response = graphql_request(consent_query, { site_id: SecureRandom.uuid }, nil)

      expect(response['data']['consent']).to eq nil
    end
  end

  context 'when the site has consent saved' do
    let(:site) { create(:site) }

    before do
      Consent.create(
        site: site,
        name: 'Squeaky',
        consent_method: 'widget',
        layout: 'bottom_left',
        privacy_policy_url: 'https://squeaky.ai/privacy',
        languages: ['en'],
        languages_default: 'en'
      )
    end

    it 'returns the consent' do
      response = graphql_request(consent_query, { site_id: site.uuid }, nil)

      expect(response['data']['consent']).to eq(
        'name' => 'Squeaky',
        'consentMethod' => 'widget',
        'layout' => 'bottom_left',
        'privacyPolicyUrl' => 'https://squeaky.ai/privacy',
        'languages' => ['en'],
        'languagesDefault' => 'en'
      )
    end
  end
end
