# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeService::Types::CustomerUpdated do
  describe '.handle' do
    let(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T', status: Billing::VALID) }
    let(:payment_id) { SecureRandom.base36 }

    let(:customer_updated_fixture) { require_fixture('stripe/customer_updated.json') }
    let(:customer_retrieved_fixture) { require_fixture('stripe/customer_retrieve.json') }
    let(:list_payments_methods_fixture) { require_fixture('stripe/list_payment_methods.json') }

    let(:event) { customer_updated_fixture['object'] }

    before do
      allow(Stripe::Customer).to receive(:retrieve)
        .with(billing.customer_id)
        .and_return(customer_retrieved_fixture)

      allow(Stripe::PaymentMethod).to receive(:list)
        .with({ customer: billing.customer_id, type: 'card' })
        .and_return(list_payments_methods_fixture)
    end

    subject { described_class.new(event).handle }

    it 'updates the billing' do
      subject
      billing.reload
      expect(billing.status).to eq(Billing::VALID)
      expect(billing.card_type).to eq('visa')
      expect(billing.country).to eq('UK')
      expect(billing.expiry).to eq('10/2025')
      expect(billing.card_number).to eq('4242')
      expect(billing.billing_name).to eq('Lewis Monteith')
      expect(billing.billing_email).to eq('lewismonteith@gmail.com')
      expect(billing.billing_address).to eq(
        'city' => nil,
        'country' => 'GB',
        'line1' => '',
        'line2' => nil,
        'postal_code' => nil,
        'state' => nil,
      )
      expect(billing.tax_ids).to eq([])
    end
  end
end