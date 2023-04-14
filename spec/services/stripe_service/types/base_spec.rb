# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeService::Types::Base do
  class Instance < StripeService::Types::Base; end

  let(:event) { double(:event) }
  let(:instance) { Instance.new(event) }

  describe '.handle' do
    subject { instance.handle }

    it 'raises a NotImplementedError' do
      expect { subject }.to raise_error(NotImplementedError, 'StripeService::Types::Base#handle not implemented')
    end
  end

  describe '.customer_id' do
    let(:customer) { double(:customer) }

    subject { instance.send(:customer_id) }

    context 'when the event references the customer as customer' do
      let(:event) { double(:event) }

      before do
        allow(event).to receive(:[])
          .with('customer')
          .and_return(customer)
      end

      it 'returns the customer' do
        expect(subject).to eq(customer)
      end
    end

    context 'when the event references the customer as id' do
      let(:event) { double(:event) }

      before do
        allow(event).to receive(:[])
          .with('customer')
          .and_return(nil)

        allow(event).to receive(:[])
          .with('id')
          .and_return(customer)
      end

      it 'returns the customer' do
        expect(subject).to eq(customer)
      end
    end
  end

  describe '.billing' do
    subject { instance.send(:billing) }

    context 'when the billing exists' do
      let(:billing) { create(:billing) }

      before do
        allow(event).to receive(:[])
          .with('customer')
          .and_return(billing.customer_id)
      end

      it 'returns the billing' do
        expect(subject).to eq(billing)
      end
    end

    context 'when the billing does not exist' do
      let(:customer) { rand }

      before do
        allow(event).to receive(:[])
          .with('customer')
          .and_return(customer)
      end

      it 'raises an error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.site' do
    let(:billing) { create(:billing) }

    before do
      allow(event).to receive(:[])
        .with('customer')
        .and_return(billing.customer_id)
    end

    subject { instance.send(:site) }

    it 'returns the site' do
      expect(subject).to eq(billing.site)
    end
  end

  describe '.user' do
    let(:billing) { create(:billing) }

    before do
      allow(event).to receive(:[])
        .with('customer')
        .and_return(billing.customer_id)
    end

    subject { instance.send(:user) }

    it 'returns the user' do
      expect(subject).to eq(billing.user)
    end
  end

  describe '.stripe_customer' do
    let(:billing) { create(:billing) }
    let(:customer) { double(:customer) }

    before do
      allow(event).to receive(:[])
        .with('customer')
        .and_return(billing.customer_id)

      allow(Stripe::Customer).to receive(:retrieve)
        .with(billing.customer_id)
        .and_return(customer)
    end

    subject { instance.send(:stripe_customer) }

    it 'returns the customer' do
      expect(subject).to eq(customer)
    end
  end

  describe '.update_billing_status' do
    let(:billing) { create(:billing) }
    let(:status) { Billing::INVALID }

    before do
      allow(event).to receive(:[])
        .with('customer')
        .and_return(billing.customer_id)
    end

    subject { instance.send(:update_billing_status, status) }

    it 'updates the status' do
      expect { subject }.to change { billing.reload.status }.from(Billing::NEW).to(status)
    end
  end

  describe '.refresh_customer_payment_information!' do
    let(:billing) { create(:billing) }
    let(:payment_id) { SecureRandom.base36 }

    subject { instance.send(:refresh_customer_payment_information!) }

    before do
      allow(event).to receive(:[])
        .with('customer')
        .and_return(billing.customer_id)

      allow(Stripe::Customer).to receive(:retrieve)
        .with(billing.customer_id)
        .and_return('invoice_settings' => { 'default_payment_method' => payment_id })

      allow(Stripe::PaymentMethod).to receive(:retrieve)
        .with(payment_id)
        .and_return(
          'card' => {
            'brand' => 'visa',
            'country' => 'UK',
            'exp_month' => 1,
            'exp_year' => 3000,
            'last4' => '0000'
          },
          'billing_details' => {
            'name' => 'Bob Dylan',
            'email' => 'bigbob2022@gmail.com',
            'address' => {
              'line1' => 'Hollywood',
              'country' => 'US'
            }
          }
        )
    end

    it 'updates the users billing information' do
      subject
      billing.reload

      expect(billing.card_type).to eq 'visa'
      expect(billing.country).to eq 'UK'
      expect(billing.expiry).to eq '1/3000'
      expect(billing.card_number).to eq '0000'
      expect(billing.billing_name).to eq 'Bob Dylan'
      expect(billing.billing_email).to eq 'bigbob2022@gmail.com'
    end
  end
end
