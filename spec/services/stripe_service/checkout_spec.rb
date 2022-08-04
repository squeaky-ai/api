# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeService::Checkout do
  describe '.create_plan' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:pricing_id) { double(:pricing_id) }
    let(:customer_id) { SecureRandom.base36 }
    let(:redirect_url) { 'https://stripe.com/fake_redirect_url' }

    let(:customer_response) { { 'id' => customer_id } }
    let(:payments_response) { { 'url' => redirect_url } }

    subject { described_class.new(user, site).create_plan(pricing_id) }

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
          customer_update: {
            address: 'auto', 
            name: 'auto'
          },
          allow_promotion_codes: true,
          billing_address_collection: 'required',
          metadata: {
            site: site.name
          },
          success_url: "#{Rails.application.config.web_host}/app/sites/#{site.id}/settings/subscription?billing_setup_success=1",
          cancel_url: "#{Rails.application.config.web_host}/app/sites/#{site.id}/settings/subscription?billing_setup_success=0",
          mode: 'subscription',
          line_items: [
            {
              quantity: 1,
              price: pricing_id
            }
          ],
          tax_id_collection: {
            enabled: true
          }
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

  describe '.create_billing' do
    let(:billing) { create(:billing) }
    let(:redirect_url) { 'https://stripe.com/fake_redirect_url' }
    let(:portal_response) { { 'url' => redirect_url } }

    subject { described_class.new(billing.user, billing.site).create_billing }

    before do
      allow(Stripe::BillingPortal::Session).to receive(:create)
        .with(
          customer: billing.customer_id,
          return_url: "#{Rails.application.config.web_host}/app/sites/#{billing.site.id}/settings/subscription"
        )
        .and_return(portal_response)
    end

    it 'returns the customer id and the redirect url' do
      expect(subject).to eq(customer_id: billing.customer_id, redirect_url:)
    end
  end
end
