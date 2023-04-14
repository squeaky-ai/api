# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeService::Types::InvoicePaymentFailed do
  describe '.handle' do
    let(:event) { double(:event) }
    let(:billing) { create(:billing, status: Billing::VALID) }

    before do
      allow(event).to receive(:[])
        .with('customer')
        .and_return(billing.customer_id)
    end

    subject { described_class.new(event).handle }

    it 'updates the status' do
      expect { subject }.to change { billing.reload.status }.from(Billing::VALID).to(Billing::INVALID)
    end
  end
end
