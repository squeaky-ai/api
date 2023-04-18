# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeService::EventFactory do
  describe '#for' do
    let(:type) { nil }
    let(:event) { double(:event) }

    subject { described_class.for(type, event) }

    context 'when the type is CHECKOUT_SESSION_COMPLETED' do
      let(:type) { StripeService::CHECKOUT_SESSION_COMPLETED }

      it 'returns an instance of CheckoutSessionCompleted' do
        expect(subject).to be_instance_of(StripeService::Types::CheckoutSessionCompleted)
      end
    end

    context 'when the type is INVOICE_PAID' do
      let(:type) { StripeService::INVOICE_PAID }

      it 'returns an instance of InvoicePaid' do
        expect(subject).to be_instance_of(StripeService::Types::InvoicePaid)
      end
    end

    context 'when the type is INVOICE_PAYMENT_FAILED' do
      let(:type) { StripeService::INVOICE_PAYMENT_FAILED }

      it 'returns an instance of InvoicePaymentFailed' do
        expect(subject).to be_instance_of(StripeService::Types::InvoicePaymentFailed)
      end
    end

    context 'when the type is CUSTOMER_UPDATED' do
      let(:type) { StripeService::CUSTOMER_UPDATED }

      it 'returns an instance of CustomerUpdated' do
        expect(subject).to be_instance_of(StripeService::Types::CustomerUpdated)
      end
    end

    context 'when the type is TAX_ID_CREATED' do
      let(:type) { StripeService::TAX_ID_CREATED }

      it 'returns an instance of TaxIdCreated' do
        expect(subject).to be_instance_of(StripeService::Types::TaxIdCreated)
      end
    end

    context 'when the type is TAX_ID_DELETED' do
      let(:type) { StripeService::TAX_ID_DELETED }

      it 'returns an instance of TaxIdDeleted' do
        expect(subject).to be_instance_of(StripeService::Types::TaxIdDeleted)
      end
    end

    context 'when the type is not handled' do
      let(:type) { double(:unhandled_type) }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end
end
