# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeService::Types::TaxIdDeleted do
  describe '.handle' do
    context 'when the tax_id does not exist' do
      let(:tax_id_deleted_fixture) { require_fixture('stripe/tax_id_deleted.json') }
      let(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T') }

      let(:event) { tax_id_deleted_fixture['object'] }

      subject { described_class.new(event).handle }

      it 'does nothing' do
        expect { subject }.not_to(change { billing.reload.tax_ids })
      end
    end

    context 'when the tax_id does exist' do
      let(:tax_id_deleted_fixture) { require_fixture('stripe/tax_id_deleted.json') }
      let(:billing) do
        create(
          :billing,
          customer_id: 'cus_LYkhU0zACd6T4T',
          tax_ids: [{ type: 'eu_vat', value: 'XI123345678' }]
        )
      end

      let(:event) { tax_id_deleted_fixture['object'] }

      subject { described_class.new(event).handle }

      it 'removes the entry' do
        expect { subject }.to change { billing.reload.tax_ids }
          .from([{ 'type' => 'eu_vat', 'value' => 'XI123345678' }])
          .to([])
      end
    end

    context 'when the tax_id does exist and there are others' do
      let(:tax_id_deleted_fixture) { require_fixture('stripe/tax_id_deleted.json') }
      let(:billing) do
        create(
          :billing,
          customer_id: 'cus_LYkhU0zACd6T4T',
          tax_ids: [{ type: 'eu_vat', value: 'XI123345678' }, { type: 'eu_vat', value: 'xxxxxxxxxxxx' }]
        )
      end

      let(:event) { tax_id_deleted_fixture['object'] }

      subject { described_class.new(event).handle }

      it 'removes the entry' do
        expect { subject }.to change { billing.reload.tax_ids }
          .from([{ 'type' => 'eu_vat', 'value' => 'XI123345678' }, { 'type' => 'eu_vat', 'value' => 'xxxxxxxxxxxx' }])
          .to([{ 'type' => 'eu_vat', 'value' => 'xxxxxxxxxxxx' }])
      end
    end
  end
end
