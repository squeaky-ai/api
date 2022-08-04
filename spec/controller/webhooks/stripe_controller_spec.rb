# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe Webhooks::StripeController, type: :controller do
  describe 'POST /' do
    context 'when the event type is "checkout.session.completed" for a monthly customer and they do not have a preferrered payment method' do
      let(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T') }
      let(:payment_id) { SecureRandom.base36 }

      let(:monthly_checkout_session_completed_fixture) { require_fixture('stripe/monthly_checkout_session_completed.json') }
      let(:customer_retrieved_fixture) { require_fixture('stripe/customer_retrieve.json') }
      let(:list_payments_methods_fixture) { require_fixture('stripe/list_payment_methods.json') }

      let(:stripe_event) do
        double(:stripe_event, type: 'checkout.session.completed', data: double(:data, monthly_checkout_session_completed_fixture))
      end

      subject { get :index, body: '{}', as: :json }

      before do
        allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)

        allow(Stripe::Customer).to receive(:retrieve)
          .with(billing.customer_id)
          .and_return(customer_retrieved_fixture)

        allow(Stripe::PaymentMethod).to receive(:list)
          .with(customer: billing.customer_id, type: 'card')
          .and_return(list_payments_methods_fixture)
      end

      it 'returns the success message' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.body).to eq({ success: true }.to_json)
      end

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

      context 'when there are locked recordings' do
        before do
          create(:recording, site: billing.site, status: Recording::LOCKED)
          create(:recording, site: billing.site, status: Recording::LOCKED)
          create(:recording, site: billing.site, status: Recording::LOCKED)
        end
  
        it 'unlocks them' do
          expect { subject }.to change { billing.site.recordings.reload.where(status: Recording::LOCKED).size }.from(3).to(0)
        end
      end
    end

    context 'when the event type is "invoice.paid" for a monthly customer' do
      let(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T') }

      let(:invoice_paid_fixture) { require_fixture('stripe/monthly_invoice_paid.json') }
      let(:customer_retrieved_fixture) { require_fixture('stripe/customer_retrieve.json') }
      let(:list_payments_methods_fixture) { require_fixture('stripe/list_payment_methods.json') }
  
      let(:stripe_event) do
        double(:stripe_event, type: 'invoice.paid', data: double(:data, invoice_paid_fixture))
      end
  
      subject { get :index, body: '{}', as: :json }
  
      before do
        allow(Stripe::Customer).to receive(:retrieve)
          .with(billing.customer_id)
          .and_return(customer_retrieved_fixture)

        allow(Stripe::PaymentMethod).to receive(:list)
          .with(customer: billing.customer_id, type: 'card')
          .and_return(list_payments_methods_fixture)

        allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)
      end
  
      it 'returns the success message' do
        subject
  
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.body).to eq({ success: true }.to_json)
      end
  
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
        expect { subject }.to change { billing.site.reload.plan.tier }.from(0).to(1)
      end
    end

    context 'when the event type is "invoice.paid" for a yearly customer' do
      let(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T') }

      let(:invoice_paid_fixture) { require_fixture('stripe/yearly_invoice_paid.json') }
      let(:customer_retrieved_fixture) { require_fixture('stripe/customer_retrieve.json') }
      let(:list_payments_methods_fixture) { require_fixture('stripe/list_payment_methods.json') }
  
      let(:stripe_event) do
        double(:stripe_event, type: 'invoice.paid', data: double(:data, invoice_paid_fixture))
      end

      subject { get :index, body: '{}', as: :json }
  
      before do
        allow(Stripe::Customer).to receive(:retrieve)
          .with(billing.customer_id)
          .and_return(customer_retrieved_fixture)

        allow(Stripe::PaymentMethod).to receive(:list)
          .with(customer: billing.customer_id, type: 'card')
          .and_return(list_payments_methods_fixture)

        allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)
      end
  
      it 'returns the success message' do
        subject
  
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.body).to eq({ success: true }.to_json)
      end
  
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
        expect(billing.billing_address).to eq(
          'city'=> 'Fareham',
          'country' => 'GB',
          'line1' => '3 Harting Gardens',
          'line2' => '',
          'postal_code' => 'PO16 8DX',
          'state' => '',
        )
        expect(billing.tax_ids).to eq([])
      end
  
      it 'stores the invoice' do
        expect { subject }.to change { billing.reload.transactions.size }.from(0).to(1)
      end

      it 'stores the correct invoice details' do
        subject
        transaction = billing.reload.transactions.first

        expect(transaction.amount).to eq(796800)
        expect(transaction.currency).to eq('GBP')
        expect(transaction.interval).to eq('year')
        expect(transaction.period_from).to eq(1650700595)
        expect(transaction.period_to).to eq(1682236595)
        expect(transaction.discount_id).to eq(nil)
        expect(transaction.discount_name).to eq(nil)
        expect(transaction.discount_percentage).to eq(nil)
        expect(transaction.discount_amount).to eq(nil)
      end

      it 'sets the sites plan to the one from the billing' do
        expect { subject }.to change { billing.site.reload.plan.tier }.from(0).to(5)
      end
    end

    context 'when the event type is "invoice.paid" for a yearly customer and they have a coupon applied' do
      let(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T') }

      let(:invoice_paid_fixture) { require_fixture('stripe/yearly_invoice_paid_with_coupon.json') }
      let(:customer_retrieved_fixture) { require_fixture('stripe/customer_retrieve.json') }
      let(:list_payments_methods_fixture) { require_fixture('stripe/list_payment_methods.json') }
  
      let(:stripe_event) do
        double(:stripe_event, type: 'invoice.paid', data: double(:data, invoice_paid_fixture))
      end

      subject { get :index, body: '{}', as: :json }
  
      before do
        allow(Stripe::Customer).to receive(:retrieve)
          .with(billing.customer_id)
          .and_return(customer_retrieved_fixture)

        allow(Stripe::PaymentMethod).to receive(:list)
          .with(customer: billing.customer_id, type: 'card')
          .and_return(list_payments_methods_fixture)

        allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)
      end
  
      it 'returns the success message' do
        subject
  
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.body).to eq({ success: true }.to_json)
      end
  
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
        expect(billing.billing_address).to eq(
          'city'=> 'Fareham',
          'country' => 'GB',
          'line1' => '3 Harting Gardens',
          'line2' => '',
          'postal_code' => 'PO16 8DX',
          'state' => '',
        )
        expect(billing.tax_ids).to eq([])
      end
  
      it 'stores the invoice' do
        expect { subject }.to change { billing.reload.transactions.size }.from(0).to(1)
      end

      it 'stores the correct invoice details' do
        subject
        transaction = billing.reload.transactions.first

        expect(transaction.amount).to eq(4003200)
        expect(transaction.currency).to eq('GBP')
        expect(transaction.interval).to eq('year')
        expect(transaction.period_from).to eq(1650702967)
        expect(transaction.period_to).to eq(1682238967)
        expect(transaction.discount_id).to eq('di_1KreRnLJ9zG7aLW8NPzlACk5')
        expect(transaction.discount_name).to eq('Annual Payment Discount')
        expect(transaction.discount_percentage).to eq(20.0)
        expect(transaction.discount_amount).to eq(nil)
      end

      it 'sets the sites plan to the one from the billing' do
        expect { subject }.to change { billing.site.reload.plan.tier }.from(0).to(7)
      end
    end

    context 'when the event type is "invoice.paid" for a yearly customer and they have a fixed price coupon applied' do
      let(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T') }

      let(:invoice_paid_fixture) { require_fixture('stripe/yearly_invoice_paid_with_fixed_amount_coupon.json') }
      let(:customer_retrieved_fixture) { require_fixture('stripe/customer_retrieve.json') }
      let(:list_payments_methods_fixture) { require_fixture('stripe/list_payment_methods.json') }
  
      let(:stripe_event) do
        double(:stripe_event, type: 'invoice.paid', data: double(:data, invoice_paid_fixture))
      end

      subject { get :index, body: '{}', as: :json }
  
      before do
        allow(Stripe::Customer).to receive(:retrieve)
          .with(billing.customer_id)
          .and_return(customer_retrieved_fixture)

        allow(Stripe::PaymentMethod).to receive(:list)
          .with(customer: billing.customer_id, type: 'card')
          .and_return(list_payments_methods_fixture)

        allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)
      end
  
      it 'returns the success message' do
        subject
  
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.body).to eq({ success: true }.to_json)
      end
  
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
        expect(billing.billing_address).to eq(
          'city'=> 'Fareham',
          'country' => 'GB',
          'line1' => '3 Harting Gardens',
          'line2' => '',
          'postal_code' => 'PO16 8DX',
          'state' => '',
        )
        expect(billing.tax_ids).to eq([])
      end
  
      it 'stores the invoice' do
        expect { subject }.to change { billing.reload.transactions.size }.from(0).to(1)
      end

      it 'stores the correct invoice details' do
        subject
        transaction = billing.reload.transactions.first

        expect(transaction.amount).to eq(796800)
        expect(transaction.currency).to eq('GBP')
        expect(transaction.interval).to eq('year')
        expect(transaction.period_from).to eq(1650827774)
        expect(transaction.period_to).to eq(1682363774)
        expect(transaction.discount_id).to eq('di_1KsAuoLJ9zG7aLW8LGq2lcnj')
        expect(transaction.discount_name).to eq('Annual Payment Discount')
        expect(transaction.discount_percentage).to eq(nil)
        expect(transaction.discount_amount).to eq(561600)
      end

      it 'sets the sites plan to the one from the billing' do
        expect { subject }.to change { billing.site.reload.plan.tier }.from(0).to(5)
      end
    end

    context 'when the event type is "invoice.paid" for a monthly customer and they provided an address' do
      let(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T') }

      let(:invoice_paid_fixture) { require_fixture('stripe/monthly_invoice_paid_with_address.json') }
      let(:customer_retrieved_fixture) { require_fixture('stripe/customer_retrieve.json') }
      let(:list_payments_methods_fixture) { require_fixture('stripe/list_payment_methods.json') }
  
      let(:stripe_event) do
        double(:stripe_event, type: 'invoice.paid', data: double(:data, invoice_paid_fixture))
      end
  
      subject { get :index, body: '{}', as: :json }
  
      before do
        allow(Stripe::Customer).to receive(:retrieve)
          .with(billing.customer_id)
          .and_return(customer_retrieved_fixture)

        allow(Stripe::PaymentMethod).to receive(:list)
          .with(customer: billing.customer_id, type: 'card')
          .and_return(list_payments_methods_fixture)

        allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)
      end
  
      it 'returns the success message' do
        subject
  
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.body).to eq({ success: true }.to_json)
      end
  
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
        expect(billing.billing_address).to eq(
          'city'=> 'Fareham',
          'country' => 'GB',
          'line1' => '3 Harting Gardens',
          'line2' => 'Portchester',
          'postal_code' => 'PO16 8DX',
          'state' => nil,
        )
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
        expect(transaction.period_from).to eq(1659454190)
        expect(transaction.period_to).to eq(1662132590)
        expect(transaction.discount_id).to eq(nil)
        expect(transaction.discount_name).to eq(nil)
        expect(transaction.discount_percentage).to eq(nil)
        expect(transaction.discount_amount).to eq(nil)
      end

      it 'sets the sites plan to the one from the billing' do
        expect { subject }.to change { billing.site.reload.plan.tier }.from(0).to(1)
      end
    end

    context 'when the event type is "invoice.paid" for a monthly customer and they provided their tax info' do
      let(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T') }

      let(:invoice_paid_fixture) { require_fixture('stripe/monthly_invoice_paid_with_address_and_tax.json') }
      let(:customer_retrieved_fixture) { require_fixture('stripe/customer_retrieve.json') }
      let(:list_payments_methods_fixture) { require_fixture('stripe/list_payment_methods.json') }
  
      let(:stripe_event) do
        double(:stripe_event, type: 'invoice.paid', data: double(:data, invoice_paid_fixture))
      end
  
      subject { get :index, body: '{}', as: :json }
  
      before do
        allow(Stripe::Customer).to receive(:retrieve)
          .with(billing.customer_id)
          .and_return(customer_retrieved_fixture)

        allow(Stripe::PaymentMethod).to receive(:list)
          .with(customer: billing.customer_id, type: 'card')
          .and_return(list_payments_methods_fixture)

        allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)
      end
  
      it 'returns the success message' do
        subject
  
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.body).to eq({ success: true }.to_json)
      end
  
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
        expect(billing.billing_address).to eq(
          'city'=> 'Fareham',
          'country' => 'GB',
          'line1' => '3 Harting Gardens',
          'line2' => 'Portchester',
          'postal_code' => 'PO16 8DX',
          'state' => nil,
        )
        expect(billing.tax_ids).to eq([
          {
            'type' => 'gb_vat',
            'value' => 'GB123456789'
          }
        ])
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
        expect(transaction.period_from).to eq(1659466887)
        expect(transaction.period_to).to eq(1662145287)
        expect(transaction.discount_id).to eq(nil)
        expect(transaction.discount_name).to eq(nil)
        expect(transaction.discount_percentage).to eq(nil)
        expect(transaction.discount_amount).to eq(nil)
      end

      it 'sets the sites plan to the one from the billing' do
        expect { subject }.to change { billing.site.reload.plan.tier }.from(0).to(1)
      end
    end
  
    context 'when the event type is "invoice.payment_failed"' do
      let(:billing) { create(:billing) }
  
      let(:stripe_event) do
        double(
          :stripe_event, 
          type: 'invoice.payment_failed',
          data: double(:data, object: { 'customer' => billing.customer_id })
        )
      end
  
      subject { get :index, body: '{}', as: :json }
  
      before do
        allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)
      end
  
      it 'returns the success message' do
        subject
  
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.body).to eq({ success: true }.to_json)
      end
  
      it 'sets the billing status to be invalid' do
        expect { subject }.to change { billing.reload.status }.from(Billing::NEW).to(Billing::INVALID)
      end
    end
  end

  context 'when the event type is "customer.updated"' do
    let(:billing) { create(:billing, customer_id: 'cus_LYkhU0zACd6T4T', status: Billing::VALID) }
    let(:payment_id) { SecureRandom.base36 }

    let(:customer_updated_fixture) { require_fixture('stripe/customer_updated.json') }
    let(:customer_retrieved_fixture) { require_fixture('stripe/customer_retrieve.json') }
    let(:list_payments_methods_fixture) { require_fixture('stripe/list_payment_methods.json') }

    let(:stripe_event) do
      double(
        :stripe_event, 
        type: 'customer.updated',
        data: double(:data, customer_updated_fixture)
      )
    end

    subject { get :index, body: '{}', as: :json }

    before do
      allow(Stripe::Customer).to receive(:retrieve)
        .with(billing.customer_id)
        .and_return(customer_retrieved_fixture)

      allow(Stripe::PaymentMethod).to receive(:list)
        .with(customer: billing.customer_id, type: 'card')
        .and_return(list_payments_methods_fixture)

      allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)
    end

    it 'returns the success message' do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response.body).to eq({ success: true }.to_json)
    end

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
