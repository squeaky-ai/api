# frozen_string_literal: true

class StripeService
  class << self
    def create(user, site, pricing_id)
      stripe = new(user, site)

      customer = stripe.create_customer!
      redirect_url = stripe.create_checkout_session(customer, pricing_id)

      {
        redirect_url:,
        customer_id: customer.customer_id
      }
    end

    def update_status(customer_id, status)
      customer = Customer.find_by(customer_id:)

      customer.status = status
      customer.save!
    end
  end

  def initialize(user, site)
    @user = user
    @site = site
  end

  def create_customer!
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
    Customer.create!(customer_id: customer['id'], user: @user, site: @site)
  end

  def create_checkout_session(customer, pricing_id)
    response = Stripe::Checkout::Session.create(
      customer: customer.customer_id,
      metadata: {
        site: @site.name
      },
      success_url: "https://squeaky.ai/app/sites/#{@site.id}/subscription?success=1",
      cancel_url: "https://squeaky.ai/app/sites/#{@site.id}/subscription?success=0",
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
