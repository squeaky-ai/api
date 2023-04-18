# typed: false
# frozen_string_literal: true

module StripeService
  class Checkout
    def initialize(user, site)
      @user = user
      @site = site
    end

    def create_plan(pricing_id)
      billing = find_or_create_billing!
      redirect_url = create_checkout_session(billing, pricing_id)

      {
        redirect_url:,
        customer_id: billing.customer_id
      }
    end

    def create_billing_portal
      billing = find_or_create_billing!
      redirect_url = create_billing_portal_session(billing.customer_id)

      {
        redirect_url:,
        customer_id: billing.customer_id
      }
    end

    private

    attr_reader :user, :site

    def find_or_create_billing!
      if site.billing
        # It may exist where the customer exists but is in
        # a weird state, but this should work fine until
        # that comes up
        Rails.logger.info "Billing already exists for #{site.id}"
        return site.billing
      end

      customer = create_stripe_customer

      # Create a record of the customer using the stripe
      # customer id. A user can have multiple customer
      # records (as they could own multiple sites), but a
      # site can have only one customer record
      ::Billing.create!(customer_id: customer['id'], user:, site:)
    end

    def create_billing_portal_session(customer_id)
      response = Stripe::BillingPortal::Session.create(
        customer: customer_id,
        return_url: "#{Rails.application.config.web_host}/app/sites/#{site.id}/settings/subscription"
      )

      response['url']
    end

    def create_stripe_customer
      # Create a stripe customer first so we have a stripe
      # customer id to store against our own record
      Stripe::Customer.create(
        email: user.email,
        name: user.full_name,
        metadata: {
          site: site.name
        }
      )
    end

    def create_checkout_session(billing, pricing_id)
      response = Stripe::Checkout::Session.create(
        customer: billing.customer_id,
        allow_promotion_codes: true,
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
        },
        customer_update: {
          name: 'auto',
          address: 'auto'
        },
        billing_address_collection: 'required'
      )

      response['url']
    end
  end
end
