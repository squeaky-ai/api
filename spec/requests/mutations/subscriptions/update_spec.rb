# frozen_string_literal: true

require 'rails_helper'

subscriptions_update_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $pricing_id: String!) {
    subscriptionsUpdate(input: { siteId: $site_id, pricingId: $pricing_id }) {
      id
      plan {
        type
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

    it 'returns the updated site' do
      response = subject['data']['subscriptionsUpdate']
      expect(response).to eq(
        'id' => site.id.to_s,
        'plan' => {
          'type' => 2,
          'name' => 'Plus'
        }
      )
    end

    it 'updates the plan' do
      expect { subject }.to change { site.reload.plan }.from(0).to(2)
    end

    it 'calls the service' do
      subject
      expect(StripeService).to have_received(:update_plan).with(
        user,
        site,
        pricing_id
      )
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
        site.update(plan: 4)

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
