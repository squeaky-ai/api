# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeService::Types::CustomerSubscriptionDeleted do
  describe '.handle' do
    let!(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T', status: Billing::VALID) }
    let(:payment_id) { SecureRandom.base36 }

    let(:customer_subscription_deleted_fixture) { require_fixture('stripe/customer_subscription_deleted.json') }

    let(:event) { customer_subscription_deleted_fixture['object'] }

    subject { described_class.new(event).handle }

    it 'puts the site on the free plan' do
      subject
      expect(billing.site.plan.free?).to eq(true)
    end
  end
end