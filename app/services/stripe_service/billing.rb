# frozen_string_literal: true

module StripeService
  class Billing
    def initialize(user, site)
      @user = user
      @site = site
    end

    def update_plan(pricing_id)
      subscription = fetch_subscription
      update_subscription_price_id(subscription[:id], subscription[:item_id], pricing_id)
    end

    def delete_customer(customer_id)
      Stripe::Customer.delete(customer_id)
    end

    private

    attr_reader :user, :site

    def fetch_subscription
      billing = site.billing

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
end
