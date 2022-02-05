# frozen_string_literal: true

require 'rails_helper'

sites_billing_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      id
      billing {
        customerId
        status
        cardType
        country
        expiry
        cardNumber
        billingAddress
        billingName
        billingEmail
      }
    }
  }
GRAPHQL

RSpec.describe 'QuerySitesBilling', type: :request do
  context 'when the site is not set up for billing' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    it 'returns nil' do
      response = graphql_request(sites_billing_query, { site_id: site.id }, user)

      expect(response['data']['site']['billing']).to eq nil
    end
  end

  context 'when the site is set up for billing' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      billing = Billing.create(
        customer_id: 'id',
        status: 'valid',
        card_type: 'visa',
        country: 'NL',
        expiry: '5/30',
        card_number: '1234',
        billing_address: 'My house, US',
        billing_name: 'Teapot McKettle',
        billing_email: 'email@email.com',
        user: user, 
        site: site
      )
    end

    it 'returns the billing info' do
      response = graphql_request(sites_billing_query, { site_id: site.id }, user)

      expect(response['data']['site']['billing']).to eq(
        'customerId' => 'id',
        'cardNumber' => '1234',
        'cardType' => 'visa',
        'status' => 'valid',
        'country' => 'NL',
        'expiry' => '5/30',
        'billingAddress' => 'My house, US', 
        'billingEmail' => 'email@email.com', 
        'billingName' => 'Teapot McKettle'
      )
    end
  end
end
