# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeService do
  describe '.create' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:pricing_id) { double(:pricing_id) }
    let(:customer_id) { SecureRandom.base36 }
    let(:redirect_url) { 'https://stripe.com/fake_redirect_url' }

    let(:customer_response) { { 'id' => customer_id } }
    let(:payments_response) { { 'url' => redirect_url } }

    subject { StripeService.create_plan(user, site, pricing_id) }

    before do
      allow(Stripe::Customer).to receive(:create)
        .with(
          email: user.email,
          name: user.full_name,
          metadata: {
            site: site.name
          }
        )
        .and_return(customer_response)

      allow(Stripe::Checkout::Session).to receive(:create)
        .with(
          customer: customer_id,
          metadata: {
            site: site.name
          },
          success_url: "https://squeaky.ai/app/sites/#{site.id}/settings/subscription?billing_setup_success=1",
          cancel_url: "https://squeaky.ai/app/sites/#{site.id}/settings/subscription?billing_setup_success=0",
          mode: 'subscription',
          line_items: [
            {
              quantity: 1,
              price: pricing_id
            }
          ]
        )
        .and_return(payments_response)
    end

    it 'returns the customer id and the redirect url' do
      expect(subject).to eq(customer_id:, redirect_url:)
    end

    it 'creates the stripe customer' do
      subject
      expect(Stripe::Customer).to have_received(:create)
    end

    it 'creates the stripe checkout' do
      subject
      expect(Stripe::Checkout::Session).to have_received(:create)
    end

    it 'creates a billing record in the database' do
      subject
      billing = site.reload.billing

      expect(billing.customer_id).to eq customer_id
      expect(billing.site_id).to eq site.id
      expect(billing.user_id).to eq user.id
      expect(billing.status).to eq 'new'
    end

    context 'when the site already has billing' do
      before do
        Billing.create(customer_id:, site: site, user: user)
      end

      it 'returns the customer id and the redirect url' do
        expect(subject).to eq(customer_id:, redirect_url:)
      end

      it 'does not create a new stripe customer' do
        subject
        expect(Stripe::Customer).not_to have_received(:create)
      end

      it 'does not create a new billing record' do
        expect { subject }.not_to change { Billing.count }
      end
    end
  end

  describe '.update_plan' do
    let(:billing) { create(:billing) }
    let(:pricing_id) { double(:pricing_id) }

    let(:subscription_id) { SecureRandom.base36 }
    let(:subscription_item_id) { SecureRandom.base36 }

    let(:list_subscriptions_response) do
      double(
        :list_subscriptions_response,
        data: [
          {
            'id' => subscription_id,
            'items' => {
              'data' => [
                {
                  'id' => subscription_item_id
                }
              ]
            }
          }
        ]
      )
    end

    subject { StripeService.update_plan(billing.user, billing.site, pricing_id) }

    before do
      allow(Stripe::Subscription).to receive(:list)
        .with(
          customer: billing.customer_id,
          limit: 1
        )
        .and_return(list_subscriptions_response)

      allow(Stripe::Subscription).to receive(:update)
        .with(
          subscription_id,
          {
            cancel_at_period_end: false,
            proration_behavior: 'always_invoice',
            items: [
              {
                id: subscription_item_id,
                price: pricing_id
              }
            ]
          }
        )
    end

    it 'calls stripe to update the subscription' do
      subject
      expect(Stripe::Subscription).to have_received(:update)
    end
  end

  describe '.update_status' do
    let(:billing) { create(:billing) }
    let(:status) { 'invalid' }

    subject { StripeService.update_status(billing.customer_id, status) }

    it 'updates the status' do
      expect { subject }.to change { billing.reload.status }.from('new').to(status)
    end
  end

  describe '.update_customer' do
    let(:billing) { create(:billing) }
    let(:payment_id) { SecureRandom.base36 }

    let(:payment_methods_response) do
      double(:payment_methods_response, data: {
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
      })
    end

    subject { StripeService.update_customer(billing.customer_id) }

    before do
      allow(Stripe::Customer).to receive(:retrieve)
        .with(billing.customer_id)
        .and_return('invoice_settings' => { 'default_payment_method' => payment_id })

      allow(Stripe::PaymentMethod).to receive(:retrieve)
        .with(payment_id)
        .and_return(payment_methods_response)
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

  describe '.store_transaction' do
    let(:billing) { create(:billing) }

    let(:transaction_event) do
      {
        'hosted_invoice_url' => 'http://stripe.com/web',
        'invoice_pdf' => 'http://stripe.com/pdf',
        'lines' => {
          'data' => [
            {
              'amount' => 1000,
              'currency' => 'usd',
              'period' => {
                'start' => 1644052149,
                'end' => 1646471349
              },
              'plan' => {
                'id' => 'price_1KPOV6LJ9zG7aLW8tDzfMy0D',
                'interval' => 'month'
              }
            }
          ]
        }
      }
    end

    subject { StripeService.store_transaction(billing.customer_id, transaction_event) }

    it 'stores the transaction' do
      expect { subject }.to change { billing.reload.transactions.size }.from(0).to(1)
    end

    it 'stores the expected information' do
      subject
      transaction = billing.reload.transactions.first

      expect(transaction.amount).to eq 1000
      expect(transaction.currency).to eq 'USD'
      expect(transaction.invoice_web_url).to eq 'http://stripe.com/web'
      expect(transaction.invoice_pdf_url).to eq 'http://stripe.com/pdf'
      expect(transaction.interval).to eq 'month'
      expect(transaction.pricing_id).to eq 'price_1KPOV6LJ9zG7aLW8tDzfMy0D'
      expect(transaction.period_start_at).to eq '2022-02-05 09:09:09 UTC'
      expect(transaction.period_end_at).to eq '2022-03-05 09:09:09 UTC'
    end
  end

  describe '.create_billing_portal' do
    let(:billing) { create(:billing) }
    let(:redirect_url) { 'https://stripe.com/fake_redirect_url' }
    let(:portal_response) { { 'url' => redirect_url } }

    subject { StripeService.create_billing_portal(billing.user, billing.site) }

    before do
      allow(Stripe::BillingPortal::Session).to receive(:create)
        .with(
          customer: billing.customer_id,
          return_url: "https://squeaky.ai/app/sites/#{billing.site.id}/settings/subscription"
        )
        .and_return(portal_response)
    end

    it 'returns the customer id and the redirect url' do
      expect(subject).to eq(customer_id: billing.customer_id, redirect_url:)
    end
  end
end
