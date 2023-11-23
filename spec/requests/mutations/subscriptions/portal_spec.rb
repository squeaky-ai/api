# frozen_string_literal: true

require 'rails_helper'

subscriptions_portal_mutation = <<-GRAPHQL
  mutation($input: SubscriptionsPortalInput!) {
    subscriptionsPortal(input: $input) {
      customerId
      redirectUrl
    }
  }
GRAPHQL

RSpec.describe Mutations::Subscriptions::Portal, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }
  let(:billing) { create(:billing, user:, site:) }

  let(:redirect_url) { 'https://stripe.com/fake_redirect_url' }
  let(:portal_response) { { 'url' => redirect_url } }

  before do
    allow(Stripe::BillingPortal::Session).to receive(:create)
      .with({
              customer: billing.customer_id,
              return_url: "#{Rails.application.config.web_host}/app/sites/#{site.id}/settings/subscription"
            })
      .and_return(portal_response)
  end

  subject do
    variables = {
      input: {
        siteId: billing.site.id
      }
    }
    graphql_request(subscriptions_portal_mutation, variables, user)
  end

  it 'returns the customer id and redirect url' do
    response = subject['data']['subscriptionsPortal']

    expect(response).to eq(
      'customerId' => billing.customer_id,
      'redirectUrl' => redirect_url
    )
  end
end
