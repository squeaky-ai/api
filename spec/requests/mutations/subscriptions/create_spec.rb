# frozen_string_literal: true

require 'rails_helper'

subscriptions_create_mutation = <<-GRAPHQL
  mutation($input: SubscriptionsCreateInput!) {
    subscriptionsCreate(input: $input) {
      customerId
      redirectUrl
    }
  }
GRAPHQL

RSpec.describe Mutations::Subscriptions::Create, type: :request do
  context 'when the pricing id is not valid' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          pricingId: 'teapot' 
        }
      }
      graphql_request(subscriptions_create_mutation, variables, user)
    end

    it 'returns an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'pricing_id is not valid'
    end
  end

  context 'when the pricing id is valid' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:customer_id) { SecureRandom.base36 }
    let(:pricing_id) { 'price_1KPOVlLJ9zG7aLW88SC9VKKB' }
    let(:redirect_url) { 'https://stripe.com/fake_redirect_url' }

    let(:customer_response) { { 'id' => customer_id } }
    let(:payments_response) { { 'url' => redirect_url } }

    before do
      allow(Stripe::Customer).to receive(:create)
        .with({
          email: user.email,
          name: user.full_name,
          metadata: {
            site: site.name
          }
        })
        .and_return(customer_response)

      allow(Stripe::Checkout::Session).to receive(:create)
        .with({
          customer: customer_id,
          customer_update: {
            address: 'auto', 
            name: 'auto'
          },
          allow_promotion_codes: true,
          billing_address_collection: 'required',
          metadata: {
            site: site.name
          },
          success_url: "#{Rails.application.config.web_host}/app/sites/#{site.id}/settings/subscription?billing_setup_success=1",
          cancel_url: "#{Rails.application.config.web_host}/app/sites/#{site.id}/settings/subscription?billing_setup_success=0",
          mode: 'subscription',
          line_items: [
            {
              quantity: 1,
              price: pricing_id
            }
          ],
          tax_id_collection: {
            enabled: true
          }
        })
        .and_return(payments_response)
    end

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          pricingId: pricing_id 
        }
      }
      graphql_request(subscriptions_create_mutation, variables, user)
    end

    it 'returns the customer id and redirect url' do
      response = subject['data']['subscriptionsCreate']
      expect(response).to eq(
        'customerId' => customer_id,
        'redirectUrl' => redirect_url
      )
    end
  end
end
