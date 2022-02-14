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
        billingName
        billingEmail
        transactions {
          amount
          currency
          invoiceWebUrl
          invoicePdfUrl
          interval
          plan {
            name
          }
          periodStartAt
          periodEndAt
        }
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
        status: Billing::VALID,
        card_type: 'visa',
        country: 'NL',
        expiry: '5/30',
        card_number: '1234',
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
        'status' => Billing::VALID,
        'country' => 'NL',
        'expiry' => '5/30',
        'billingEmail' => 'email@email.com', 
        'billingName' => 'Teapot McKettle',
        'transactions' => []
      )
    end
  end

  context 'when the billing has transactions' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      billing = Billing.create(
        customer_id: 'id',
        status: Billing::VALID,
        card_type: 'visa',
        country: 'NL',
        expiry: '5/30',
        card_number: '1234',
        billing_name: 'Teapot McKettle',
        billing_email: 'email@email.com',
        user: user, 
        site: site
      )

      billing.transactions << Transaction.create(
        amount: 1000,
        currency: 'USD',
        invoice_web_url: 'http://stripe.com/web',
        invoice_pdf_url: 'http://stripe.com/pdf',
        interval: 'month',
        pricing_id: 'price_1KPOWCLJ9zG7aLW8jXWVkVsr',
        period_from: 1644071095,
        period_to: 1644071104
      )
      
      billing.save
    end

    it 'returns the transaction info' do
      response = graphql_request(sites_billing_query, { site_id: site.id }, user)

      expect(response['data']['site']['billing']['transactions']).to eq(
        [
          {
            'amount' => 1000,
            'currency' => 'USD',
            'invoiceWebUrl' => 'http://stripe.com/web',
            'invoicePdfUrl' => 'http://stripe.com/pdf',
            'interval' => 'month',
            'plan' => {
              'name' => 'Business'
            },
            'periodStartAt' => '2022-02-05',
            'periodEndAt' => '2022-02-05'
          }
        ]
      )
    end
  end
end
