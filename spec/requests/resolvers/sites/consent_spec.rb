# typed: false
# frozen_string_literal: true

require 'rails_helper'

site_consent_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      consent {
        name
        consentMethod
        layout
        privacyPolicyUrl
        languages
        languagesDefault
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::Consent, type: :request do
  context 'when there is no consent' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_consent_query, variables, user)
    end

    it 'creates it' do
      expect { subject }.to change { site.reload.consent.nil? }.from(true).to(false)
    end

    it 'returns the created data' do
      response = subject['data']['site']['consent']
      expect(response).to eq(
        'consentMethod' => 'disabled',
        'languages' => ['en'],
        'languagesDefault' => 'en',
        'layout' => 'bottom_left',
        'name' => site.name,
        'privacyPolicyUrl' => "#{site.url}/privacy"
      )
    end
  end

  context 'when there is consent' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before { create(:consent, site:) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_consent_query, variables, user)
    end

    it 'does not create it' do
      expect { subject }.not_to change { Consent.all.count }
    end

    it 'returns the existing' do
      response = subject['data']['site']['consent']
      expect(response).to eq(
        'consentMethod' => site.consent.consent_method,
        'languages' => site.consent.languages,
        'languagesDefault' => site.consent.languages_default,
        'layout' => site.consent.layout,
        'name' => site.consent.name,
        'privacyPolicyUrl' => site.consent.privacy_policy_url
      )
    end
  end
end
