# frozen_string_literal: true

class StripeService
  class << self
    # Generate a URL to send the customer off to
    # so they can configure billing for the first
    # time
    def create_plan(user, site, pricing_id)
      stripe = new(user, site)

      billing = stripe.find_or_create_customer!
      redirect_url = stripe.create_checkout_session(billing, pricing_id)

      {
        redirect_url:,
        customer_id: billing.customer_id
      }
    end

    # Update the plan with a new pricing id. The site can
    # be updated immediately too, and if the billing fails
    # then we can leave them on the new plan but with invalid
    # billing
    def update_plan(user, site, pricing_id)
      stripe = new(user, site)

      # Get the ids required to update the subscription
      subscription = stripe.fetch_subscription

      stripe.update_subscription_price_id(subscription[:id], subscription[:item_id], pricing_id)
    end

    # Update the status of the billing based on
    # webhook events
    def update_status(customer_id, status)
      billing = Billing.find_by(customer_id:)

      billing.status = status
      billing.save!
    end

    # When the customer first sets up billing we
    # fetch the billing information and store it
    # in the billing table so we don't have to
    # keep querying stripe. We also unlock all of
    # their recordings because we're generous
    def init_new_billing(customer_id)
      billing = Billing.find_by(customer_id:)

      stripe = new(billing.user, billing.site)

      payment_information = stripe.fetch_payment_information(billing.customer_id)
      billing.update(payment_information)
      billing.site.unlock_recordings!
    end

    def delete_customer(customer_id)
      Stripe::Customer.delete(customer_id)
    end

    # When an invoice comes in we get the billing
    # data from the webhook event and store it in the
    # transactions table
    def store_transaction(customer_id, invoice_paid_event)
      billing = Billing.find_by(customer_id:)

      bill = invoice_paid_event['lines']['data'].first

      Transaction.create(
        billing:,
        amount: bill['amount'],
        currency: bill['currency'].upcase,
        invoice_web_url: invoice_paid_event['hosted_invoice_url'],
        invoice_pdf_url: invoice_paid_event['invoice_pdf'],
        interval: bill['plan']['interval'],
        pricing_id: bill['plan']['id'],
        period_from: bill['period']['start'],
        period_to: bill['period']['end']
      )
    end

    # Update the plan value that's assigned to the site
    # whenver an invoice is paid
    def update_billing(customer_id, invoice_paid_event)
      # Not sure if this is the best time to update this,
      # but we update our local copy of the sites plan
      # every time the invoice comes in so it's always up
      # to date.
      billing = Billing.find_by(customer_id:)
      # This is the plan id that they're currently on
      pricing_id = invoice_paid_event['lines']['data'].first['plan']['id']

      plan = Plan.find_by_pricing_id(pricing_id)
      billing.site.update(plan: plan[:id])
    end

    def create_billing_portal(user, site)
      stripe = new(user, site)

      billing = stripe.find_or_create_customer!
      redirect_url = stripe.create_billing_portal_session(billing.customer_id)

      {
        redirect_url:,
        customer_id: billing.customer_id
      }
    end
  end

  def initialize(user, site)
    @user = user
    @site = site
  end

  def find_or_create_customer!
    if @site.billing
      # It may exist where the customer exists but is in
      # a weird state, but this should work fine until
      # that comes up
      Rails.logger.info "Billing already exists for #{@site.id}"
      return @site.billing
    end

    # Create a stripe customer first so we have a stripe
    # customer id to store against our own record
    customer = Stripe::Customer.create(
      email: @user.email,
      name: @user.full_name,
      metadata: {
        site: @site.name
      }
    )

    # Create a record of the customer using the stripe
    # customer id. A user can have multiple customer
    # records (as they could own multiple sites), but a
    # site can have only one customer record
    Billing.create!(customer_id: customer['id'], user: @user, site: @site)
  end

  def fetch_payment_information(customer_id)
    response = Stripe::Customer.list_payment_methods(
      customer_id,
      { type: 'card' }
    )

    card = response.data.first['card']
    billing = response.data.first['billing_details']

    {
      card_type: card['brand'],
      country: card['country'],
      expiry: "#{card['exp_month']}/#{card['exp_year']}",
      card_number: card['last4'],
      billing_name: billing['name'],
      billing_email: billing['email']
    }
  end

  def create_checkout_session(billing, pricing_id)
    response = Stripe::Checkout::Session.create(
      customer: billing.customer_id,
      metadata: {
        site: @site.name
      },
      success_url: "https://squeaky.ai/app/sites/#{@site.id}/settings/subscription?billing_setup_success=1",
      cancel_url: "https://squeaky.ai/app/sites/#{@site.id}/settings/subscription?billing_setup_success=0",
      mode: 'subscription',
      line_items: [
        {
          quantity: 1,
          price: pricing_id
        }
      ]
    )

    response['url']
  end

  def create_billing_portal_session(customer_id)
    response = Stripe::BillingPortal::Session.create(
      customer: customer_id,
      return_url: "https://squeaky.ai/app/sites/#{@site.id}/settings/subscription"
    )

    response['url']
  end

  def fetch_subscription
    billing = @site.billing

    response = Stripe::Subscription.list(
      customer: billing.customer_id,
      limit: 1
    )

    subscription = response.data.first

    {
      id: subscription['id'],
      item_id: subscription['items']['data'].first['id']
    }
  end

  def update_subscription_price_id(subscription_id, item_id, pricing_id)
    Stripe::Subscription.update(
      subscription_id,
      {
        cancel_at_period_end: false,
        # This will charge the user the difference in this
        # billing cycle as they will probably be part way
        # through the month
        proration_behavior: 'always_invoice',
        items: [
          {
            id: item_id,
            price: pricing_id
          }
        ]
      }
    )
  end
end
