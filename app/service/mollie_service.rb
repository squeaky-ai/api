# frozen_string_literal: true

# The docs on creating recording payments can be found here:
# https://docs.mollie.com/payments/recurring
#
# But the simplified steps for onboarding a payment are:
#
# 1. Create a Mollie customer
# 2. Create the first payment and charge $0.00 to gain consent
# 3. Redirect the customer to the url from step 2
# 4. Wait for confirmation from the webhook
# 5. Check the user has the necessary perms via the mandates API
# 6. Set the desired amount via the subscription API
#
# Subscriptions will trigger the webhook every time a payment is taken

class MollieService
  class << self
    def create(user, site)
      service = new(user, site)

      customer = service.create_customer!
      redirect_url = service.create_payment!(customer.customer_id)

      {
        redirect_url:,
        customer_id: customer.customer_id
      }
    end
  end

  def initialize(user, site)
    @user = user
    @site = site
  end

  def create_customer!
    # Create a Mollie customer using the user details,
    # we currently only support en_US locales
    response = Mollie::Customer.create(
      name: @user.full_name,
      email: @user.email,
      locale: 'en_US'
    )

    # Create a record in the database for this customer.
    # A user can have multiple customer entries but a
    # site can have only one customer
    Customer.create(
      customer_id: response.id,
      user: @user,
      site: @site
    )
  end

  def create_payment!(customer_id)
    response = Mollie::Payment.create(
      customer_id:,
      # When creating the first payment we don't take any
      # money, we only gain concent. Once we've got confirmation
      # via the webhook we can change the plan to whatever we
      # want
      amount: { value: 0, currency: 'EUR' },
      # TODO: The docs suggest putting something unique in here
      description: 'Squeaky',
      # Once complete we take them to the subscription page
      # to let them know what's going on
      redirect_url: "https://squeaky.ai/app/sites/#{@site.id}/subscriptions?success=1",
      # Mollie will send updates to this URL
      webhook_url: 'https://squeaky.ai/api/webhooks/mollie',
      # The docs recomment taking the first payment
      sequence_type: 'first'
    )

    # Return the checkout url so the front end can
    # forward the user on to the checkout page
    response.links['checkout']['href']
  end
end
