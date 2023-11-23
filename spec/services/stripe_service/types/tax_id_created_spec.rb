# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeService::Types::TaxIdCreated do
  describe '.handle' do
    let(:tax_id_created_fixture) { require_fixture('stripe/tax_id_created.json') }
    let(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T') }

    let(:event) { tax_id_created_fixture['object'] }

    subject { described_class.new(event).handle }

    it 'adds the new tax_id' do
      expect { subject }.to change { billing.reload.tax_ids }.from([]).to(
        [
          {
            'type' => 'eu_vat',
            'value' => 'XI123345678'
          }
        ]
      )
    end
  end
end
