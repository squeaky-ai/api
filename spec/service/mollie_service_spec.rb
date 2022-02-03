# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MollieService do
  describe '.create' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:customer_id) { SecureRandom.base36 }
    let(:redirect_url) { 'https://mollie.com/fake_redirect_url' }

    let(:customer_response) { double(:customer_response, id: customer_id) }
    let(:payments_response) { double(:payments_response, links: { 'checkout' => { 'href' => redirect_url } }) }

    subject { MollieService.create(user, site) }

    before do
      allow(Mollie::Customer).to receive(:create)
        .with(
          name: user.full_name,
          email: user.email,
          locale: 'en_US'
        )
        .and_return(customer_response)

      allow(Mollie::Payment).to receive(:create)
        .with(
          customer_id:,
          amount: { value: 0, currency: 'EUR' },
          description: 'Squeaky',
          redirect_url: "https://squeaky.ai/app/sites/#{site.id}/subscriptions?success=1",
          webhook_url: 'https://squeaky.ai/api/webhooks/mollie',
          sequence_type: 'first'
        )
        .and_return(payments_response)
    end

    it 'returns the customer id and the redirect url' do
      expect(subject).to eq(customer_id:, redirect_url:)
    end

    it 'creates the mollie customer' do
      subject
      expect(Mollie::Customer).to have_received(:create)
    end

    it 'creates the mollie payment' do
      subject
      expect(Mollie::Payment).to have_received(:create)
    end

    it 'creates a customer in the database' do
      subject
      customer = site.reload.customer

      expect(customer.customer_id).to eq customer_id
      expect(customer.site_id).to eq site.id
      expect(customer.user_id).to eq user.id
    end
  end
end