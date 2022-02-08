# frozen_string_literal: true

require 'rails_helper'

subscriptions_update_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $pricing_id: String!) {
    subscriptionsUpdate(input: { siteId: $site_id, pricingId: $pricing_id }) {
      customerId
    }
  }
GRAPHQL

RSpec.describe Mutations::Subscriptions::Update, type: :request do
  context 'when the pricing id is not valid' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, pricing_id: 'teapot' }
      graphql_request(subscriptions_update_mutation, variables, user)
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
    let(:pricing_id) { 'price_1KPOVlLJ9zG7aLW892gWiiTU' }

    before do
      Billing.create(customer_id:, site: site, user: user)

      allow(StripeService).to receive(:update_plan)
    end

    subject do
      variables = { site_id: site.id, pricing_id: }
      graphql_request(subscriptions_update_mutation, variables, user)
    end

    it 'returns the billing' do
      response = subject['data']['subscriptionsUpdate']
      expect(response).to eq('customerId' => customer_id)
    end

    it 'calls the service' do
      subject
      expect(StripeService).to have_received(:update_plan).with(
        user,
        site,
        pricing_id
      )
    end
  end
end
