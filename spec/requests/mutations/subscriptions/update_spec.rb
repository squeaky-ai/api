# frozen_string_literal: true

require 'rails_helper'

subscriptions_update_mutation = <<-GRAPHQL
  mutation($input: SubscriptionsUpdateInput!) {
    subscriptionsUpdate(input: $input) {
      id
      plan {
        tier
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
      Billing.create(customer_id:, site: site, user: user)

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
          'tier' => 2,
          'name' => 'Plus'
        }
      )
    end

    it 'updates the plan' do
      expect { subject }.to change { site.plan.reload.tier }.from(0).to(2)
    end

    it 'calls the service' do
      expect_any_instance_of(StripeService::Billing).to receive(:update_plan).with(pricing_id)
      subject
    end

    context 'when there are locked recordings and they are upgrading' do
      before do
        create(:recording, site: site, status: Recording::LOCKED)
        create(:recording, site: site, status: Recording::LOCKED)
        create(:recording, site: site, status: Recording::LOCKED)
      end

      it 'unlocks the recordings' do
        expect { subject }.to change { site.recordings.reload.where(status: Recording::LOCKED).size }.from(3).to(0)
      end
    end

    context 'when there are locked recordings and they are downgrading' do
      before do
        site.plan.update(tier: 4)

        create(:recording, site: site, status: Recording::LOCKED)
        create(:recording, site: site, status: Recording::LOCKED)
        create(:recording, site: site, status: Recording::LOCKED)
      end

      it 'does not unlock the recordings' do
        expect { subject }.not_to change { site.recordings.reload.where(status: Recording::LOCKED).size }
      end
    end
  end
end
