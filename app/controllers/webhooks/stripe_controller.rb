# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    def index
      event = stripe_event

      Rails.logger.info "Incoming stripe event #{event.type} #{event.data.to_json}"

      customer_id = event.data.object['customer']

      case event.type
      when 'checkout.session.completed'
        # Sent when the customer goes through the checkout
        # flow and completes it. We need to update the customer
        # record with the new status.
        StripeService.update_status(customer_id, 'open')
        # Fetch the users payment information and store it along
        # with the customer so we have something nice to show in
        # the UI.
        StripeService.update_customer(customer_id)
        # Unlock all the recordings for this site
        StripeService.unlock_recordings(customer_id)
      when 'invoice.paid'
        # Sent when the customer pays their monthly bill, we
        # need to update the status to the latest so we keep
        # our own record to avoid rate limiting.
        StripeService.update_status(customer_id, 'valid')
        # Store the invoice so the customer has a record of their
        # payments
        StripeService.store_transaction(customer_id, event.data.object)
        # Update the site to reflect the plan they're currently on
        StripeService.update_billing(customer_id, event.data.object)
      when 'invoice.payment_failed'
        # Sent when the customer failed to pay their monthly
        # bill. We update the status in the database.
        StripeService.update_status(customer_id, 'invalid')
      when 'customer.updated'
        # The customer updated their details in the stripe portal
        # so we need to sync those with the database
        StripeService.update_customer(customer_id)
      end

      render json: { success: true }
    end

    private

    def stripe_event
      data = JSON.parse(request.body.read, symbolize_names: true)

      Stripe::Event.construct_from(data)
    end
  end
end
