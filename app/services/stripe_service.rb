# frozen_string_literal: true

class StripeService
  class << self
    def create(user, site, pricing_id)
      stripe = new(user, site)

      billing = stripe.find_or_create_customer!
      redirect_url = stripe.create_checkout_session(billing, pricing_id)

      {
        redirect_url:,
        customer_id: billing.customer_id
      }
    end

    def update_status(customer_id, status)
      billing = Billing.find_by(customer_id:)

      billing.status = status
      billing.save!
    end

    def store_payment_information(customer_id)
      billing = Billing.find_by(customer_id:)

      stripe = new(billing.user, billing.site)

      payment_information = stripe.fetch_payment_information(billing.customer_id)
      billing.update(payment_information)
    end

    def store_transaction(customer_id, stripe_event)
      billing = Billing.find_by(customer_id:)

      bill = stripe_event['lines'].first['data']

      Transaction.create(
        billing:,
        amount: bill['amount'],
        currency: bill['currency'].upcase,
        invoice_web_url: stripe_event['hosted_invoice_url'],
        invoice_pdf_url: stripe_event['invoice_pdf'],
        interval: bill['plan']['interval'],
        pricing_id: bill['plan']['id'],
        period_from: bill['period']['start'],
        period_to: bill['period']['end']
      )
    end
  end

  def initialize(user, site)
    @user = user
    @site = site
  end

  def find_or_create_customer!
    if @site.billing
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
      billing_address: "#{billing['address']['line1']}, #{billing['address']['country']}",
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
      success_url: "https://squeaky.ai/app/sites/#{@site.id}/settings/subscription?success=1",
      cancel_url: "https://squeaky.ai/app/sites/#{@site.id}/settings/subscription?success=0",
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
end
