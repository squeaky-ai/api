# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommissionService do
  let(:user) { create(:user) }
  let(:partner) { create(:partner, user:) }

  let(:instance) { described_class.new(partner) }

  context 'when the partner has no referrals' do
    it 'returns nothing for all_time_commission' do
      expect(instance.all_time_commission).to eq([])
    end

    it 'returns nothing for pay_outs' do
      expect(instance.pay_outs).to eq([])
    end
  end

  context 'when the partner has referrals' do
    context 'and when all the sites are all on the free tier' do
      before do
        site_1 = create(:site)
        site_2 = create(:site)
        site_3 = create(:site)

        site_1.plan.update(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f')
        site_2.plan.update(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f')
        site_3.plan.update(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f')

        create(:referral, partner:, site: site_1)
        create(:referral, partner:, site: site_2)
        create(:referral, partner:, site: site_3)
      end

      it 'returns nothing for all_time_commission' do
        expect(instance.all_time_commission).to eq([])
      end

      it 'returns nothing for pay_outs' do
        expect(instance.pay_outs).to eq([])
      end
    end

    context 'and when some of the sites have been paying' do
      before do
        site_1 = create(:site)
        site_2 = create(:site)
        site_3 = create(:site)

        site_1.plan.update(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f')
        site_2.plan.update(plan_id: '094f6148-22d6-4201-9c5e-20bffb68cc48')
        site_3.plan.update(plan_id: 'b2054935-4fdf-45d0-929b-853cfe8d4a1c')

        create(:referral, partner:, site: site_1)
        create(:referral, partner:, site: site_2)
        create(:referral, partner:, site: site_3)

        billing_1 = create(:billing, site: site_2)
        billing_2 = create(:billing, site: site_3)

        create(:transaction, billing: billing_1, amount: 1000, currency: 'GBP')
        create(:transaction, billing: billing_1, amount: 1500, currency: 'GBP')
        create(:transaction, billing: billing_1, amount: 5000, currency: 'GBP')
        create(:transaction, billing: billing_2, amount: 1000, currency: 'USD')
        create(:transaction, billing: billing_2, amount: 1000, currency: 'USD')
        create(:transaction, billing: billing_2, amount: 9000, currency: 'USD')
        create(:transaction, billing: billing_2, amount: -1000, currency: 'USD')
      end

      it 'returns the transaction history with the commission applied' do
        expect(instance.all_time_commission).to match_array(
          [
            {
              id: anything,
              amount: 200.0,
              currency: 'GBP'
            },
            {
              id: anything,
              amount: 300.0,
              currency: 'GBP'
            },
            {
              id: anything,
              amount: 1000.0,
              currency: 'GBP'
            },
            {
              id: anything,
              amount: 200.0,
              currency: 'USD'
            },
            {
              id: anything,
              amount: 200.0,
              currency: 'USD'
            },
            {
              id: anything,
              amount: 1800.0,
              currency: 'USD'
            }
          ]
        )
      end

      it 'returns nothing for pay_outs' do
        expect(instance.pay_outs).to eq([])
      end

      context 'and when they have had some pay outs' do
        before do
          create(:partner_invoice, partner:, status: PartnerInvoice::PAID, amount: 1000, currency: 'GBP')
          create(:partner_invoice, partner:, status: PartnerInvoice::PAID, amount: 4000, currency: 'USD')
          create(:partner_invoice, partner:, status: PartnerInvoice::PENDING, amount: 9000, currency: 'USD')
        end

        it 'returns the payouts' do
          expect(instance.pay_outs).to match(
            [
              {
                id: anything,
                amount: 1000,
                currency: 'GBP'
              },
              {
                id: anything,
                amount: 4000,
                currency: 'USD'
              }
            ]
          )
        end
      end
    end
  end
end
