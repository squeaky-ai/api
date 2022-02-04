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

    subject { StripeService.create(user, site, pricing_id) }

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
          success_url: "https://squeaky.ai/app/sites/#{site.id}/subscription?success=1",
          cancel_url: "https://squeaky.ai/app/sites/#{site.id}/subscription?success=0",
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

    it 'creates a customer in the database' do
      subject
      customer = site.reload.customer

      expect(customer.customer_id).to eq customer_id
      expect(customer.site_id).to eq site.id
      expect(customer.user_id).to eq user.id
      expect(customer.status).to eq 'new'
    end
  end

  describe '.update_status' do
    let(:customer) { create(:customer) }
    let(:status) { 'invalid' }

    subject { StripeService.update_status(customer.customer_id, status) }

    it 'updates the status' do
      expect { subject }.to change { customer.reload.status }.from('new').to(status)
    end
  end
end
