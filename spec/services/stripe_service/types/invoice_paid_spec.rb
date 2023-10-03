# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeService::Types::InvoicePaid do
  describe '.handle' do
    let(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T') }

    let(:invoice_paid_fixture) { require_fixture('stripe/monthly_invoice_paid.json') }
    let(:customer_retrieved_fixture) { require_fixture('stripe/customer_retrieve.json') }
    let(:list_payments_methods_fixture) { require_fixture('stripe/list_payment_methods.json') }

    let(:event) { invoice_paid_fixture['object'] }

    before do
      allow(Stripe::Customer).to receive(:retrieve)
        .with(billing.customer_id)
        .and_return(customer_retrieved_fixture)

      allow(Stripe::PaymentMethod).to receive(:list)
        .with({ customer: billing.customer_id, type: 'card' })
        .and_return(list_payments_methods_fixture)
    end

    subject { described_class.new(event).handle }

    it 'sets the billing status to be valid' do
      expect { subject }.to change { billing.reload.status }.from(Billing::NEW).to(Billing::VALID)
    end

    it 'stores the correct billing data' do
      subject
      billing.reload
      
      expect(billing.customer_id).to eq('cus_LYkhU0zACd6T4T')
      expect(billing.status).to eq(Billing::VALID)
      expect(billing.card_type).to eq('visa')
      expect(billing.country).to eq('UK')
      expect(billing.expiry).to eq('10/2025')
      expect(billing.card_number).to eq('4242')
      expect(billing.billing_name).to eq('Lewis Monteith')
      expect(billing.billing_email).to eq('lewismonteith@gmail.com')
      expect(billing.billing_address).to eq(nil)
      expect(billing.tax_ids).to eq([])
    end

    it 'stores the invoice' do
      expect { subject }.to change { billing.reload.transactions.size }.from(0).to(1)
    end

    it 'stores the correct invoice details' do
      subject
      transaction = billing.reload.transactions.first

      expect(transaction.amount).to eq(3800)
      expect(transaction.currency).to eq('GBP')
      expect(transaction.interval).to eq('month')
      expect(transaction.period_from).to eq(1650697044)
      expect(transaction.period_to).to eq(1653289044)
      expect(transaction.discount_id).to eq(nil)
      expect(transaction.discount_name).to eq(nil)
      expect(transaction.discount_percentage).to eq(nil)
      expect(transaction.discount_amount).to eq(nil)
    end

    it 'sets the sites plan to the one from the billing' do
      expect { subject }.to change { billing.site.reload.plan.plan_id }
        .from('05bdce28-3ac8-4c40-bd5a-48c039bd3c7f')
        .to('094f6148-22d6-4201-9c5e-20bffb68cc48')
    end

    context 'when upgrading to the business plan' do
      let(:business_plan) { Plans.find_by_plan_id('b2054935-4fdf-45d0-929b-853cfe8d4a1c') }

      before do
        stub = double
        allow(stub).to receive(:deliver_now)
        allow(SiteMailer).to receive(:business_plan_features).and_return(stub)

        allow(Plans).to receive(:find_by_pricing_id).and_return(business_plan)
      end

      it 'sends the business plan features email' do
        subject

        expect(SiteMailer).to have_received(:business_plan_features).with(billing.site)
      end
    end

    context 'when the plan had overrides set' do
      before do
        billing.site.reload.plan.update(
          features_enabled: ['dashboard'],
          team_member_limit: 5,
          max_monthly_recordings: 3000,
          data_storage_months: 2,
          response_time_hours: 24,
          support: ['Chat']
        )
      end

      it 'resets them all' do
        expect { subject }
          .to change { billing.site.reload.plan.features_enabled }
          .from(['dashboard'])
          .to([
            'dashboard',
            'visitors',
            'recordings',
            'event_tracking',
            'error_tracking',
            'site_analytics',
            'page_analytics',
            'journeys',
            'heatmaps_click_positions',
            'heatmaps_click_counts',
            'heatmaps_mouse',
            'heatmaps_scroll',
            'nps', 
            'sentiment',
            'data_export'
          ])
          .and change { billing.site.plan.team_member_limit }.from(5).to(nil)
          .and change { billing.site.plan.max_monthly_recordings }.from(3000).to(10000)
          .and change { billing.site.plan.data_storage_months }.from(2).to(12)
          .and change { billing.site.plan.response_time_hours }.from(24).to(72)
          .and change { billing.site.plan.support }.from(['Chat']).to(['Email'])
      end
    end
  end
end
