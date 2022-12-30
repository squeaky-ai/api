# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeService::Types::CheckoutSessionCompleted do
  describe '.handle' do
    let(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T') }
    let(:payment_id) { SecureRandom.base36 }

    let(:monthly_checkout_session_completed_fixture) { require_fixture('stripe/monthly_checkout_session_completed.json') }
    let(:customer_retrieved_fixture) { require_fixture('stripe/customer_retrieve.json') }
    let(:list_payments_methods_fixture) { require_fixture('stripe/list_payment_methods.json') }

    let(:event) { monthly_checkout_session_completed_fixture['object'] }

    before do
      allow(Stripe::Customer).to receive(:retrieve)
        .with(billing.customer_id)
        .and_return(customer_retrieved_fixture)

      allow(Stripe::PaymentMethod).to receive(:list)
        .with({ customer: billing.customer_id, type: 'card' })
        .and_return(list_payments_methods_fixture)
    end

    subject { described_class.new(event).handle }

    it 'sets the billing status to be open' do
      expect { subject }.to change { billing.reload.status }.from(Billing::NEW).to(Billing::OPEN)
    end

    it 'sets the billing information' do
      subject
      billing.reload

      expect(billing.card_type).to eq 'visa'
      expect(billing.country).to eq 'UK'
      expect(billing.expiry).to eq '10/2025'
      expect(billing.card_number).to eq '4242'
      expect(billing.billing_name).to eq 'Lewis Monteith'
      expect(billing.billing_email).to eq 'lewismonteith@gmail.com'
    end
  end
end
