# frozen_string_literal: true

require 'rails_helper'

consent_update_mutation = <<-GRAPHQL
  mutation($input: ConsentUpdateInput!) {
    consentUpdate(input: $input) {
      name
      consentMethod
      layout
      privacyPolicyUrl
      languages
      languagesDefault
    }
  }
GRAPHQL

RSpec.describe Mutations::Consent::Update, type: :request do
  context 'when there is nothing in the database' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          name: 'Squeaky',
          consentMethod: 'widget',
          layout: 'bottom_left',
          privacyPolicyUrl: 'https://squeaky.ai/privacy',
          languages: ['en'],
          languagesDefault: 'en'
        }
      }
      graphql_request(consent_update_mutation, variables, user)
    end

    it 'returns the data' do
      expect(subject['data']['consentUpdate']).to eq(
        'name' => 'Squeaky',
        'consentMethod' => 'widget',
        'layout' => 'bottom_left',
        'privacyPolicyUrl' => 'https://squeaky.ai/privacy',
        'languages' => ['en'],
        'languagesDefault' => 'en'
      )
    end

    it 'upserts the record' do
      expect { subject }.to change { site.reload.consent.nil? }.from(true).to(false)
    end
  end

  context 'when there is something in the database' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

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

    subject do
      variables = {
        input: {
          siteId: site.id,
          name: 'Squeaky 2',
          layout: 'center',
          languages: ['en', 'fr'],
        }
      }
      graphql_request(consent_update_mutation, variables, user)
    end

    it 'returns the data' do
      expect(subject['data']['consentUpdate']).to eq(
        'name' => 'Squeaky 2',
        'consentMethod' => 'widget',
        'layout' => 'center',
        'privacyPolicyUrl' => 'https://squeaky.ai/privacy',
        'languages' => ['en', 'fr'],
        'languagesDefault' => 'en'
      )
    end

    it 'does not create a new record' do
      expect { subject }.not_to change { site.reload.consent.nil? }
    end
  end
end
