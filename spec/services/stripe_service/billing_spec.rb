# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeService::Billing do
  describe '.update_plan' do
    let(:billing) { create(:billing) }
    let(:pricing_id) { double(:pricing_id) }

    let(:subscription_id) { SecureRandom.base36 }
    let(:subscription_item_id) { SecureRandom.base36 }

    let(:list_subscriptions_response) do
      double(
        :list_subscriptions_response,
        data: [
          {
            'id' => subscription_id,
            'items' => {
              'data' => [
                {
                  'id' => subscription_item_id
                }
              ]
            }
          }
        ]
      )
    end

    subject { described_class.new(billing.user, billing.site).update_plan(pricing_id) }

    before do
      allow(Stripe::Subscription).to receive(:list)
        .with({
          customer: billing.customer_id,
          limit: 1
        })
        .and_return(list_subscriptions_response)

      allow(Stripe::Subscription).to receive(:update)
        .with(
          subscription_id,
          {
            cancel_at_period_end: false,
            proration_behavior: 'always_invoice',
            items: [
              {
                id: subscription_item_id,
                price: pricing_id
              }
            ]
          }
        )
    end

    it 'calls stripe to update the subscription' do
      subject
      expect(Stripe::Subscription).to have_received(:update)
    end
  end

  describe '.delete_customer' do
    let(:billing) { create(:billing) }
    let(:customer_id) { SecureRandom.uuid }

    before do
      allow(Stripe::Customer).to receive(:delete)
    end

    subject { described_class.new(billing.user, billing.site).delete_customer(customer_id) }

    it 'calls the stripe delete method' do
      subject
      expect(Stripe::Customer).to have_received(:delete).with(customer_id)
    end
  end
end
