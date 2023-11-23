# frozen_string_literal: true

require 'rails_helper'

subscriptions_update_mutation = <<-GRAPHQL
  mutation($input: SubscriptionsUpdateInput!) {
    subscriptionsUpdate(input: $input) {
      id
      plan {
        planId
        name
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Subscriptions::Update, type: :request do
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
      Billing.create(customer_id:, site:, user:)

      allow_any_instance_of(StripeService::Billing).to receive(:update_plan)
    end

    subject do
      variables = {
        input: {
          siteId: site.id,
          pricingId: pricing_id
        }
      }
      graphql_request(subscriptions_update_mutation, variables, user)
    end

    it 'returns the updated site' do
      response = subject['data']['subscriptionsUpdate']
      expect(response).to eq(
        'id' => site.id.to_s,
        'plan' => {
          'planId' => 'f20c93ec-172f-46c6-914e-6a00dff3ae5f',
          'name' => 'Plus'
        }
      )
    end

    it 'updates the plan' do
      expect { subject }.to change { site.plan.reload.plan_id }
        .from('05bdce28-3ac8-4c40-bd5a-48c039bd3c7f')
        .to('f20c93ec-172f-46c6-914e-6a00dff3ae5f')
    end

    it 'calls the service' do
      expect_any_instance_of(StripeService::Billing).to receive(:update_plan).with(pricing_id)
      subject
    end
  end
end
