# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    def index
      event = stripe_event

      Rails.logger.info "Incoming stripe event #{event.type} #{event.data.to_json}"

      case event.type
      when 'checkout.session.completed'
        # Sent when the customer goes through the checkout
        # flow and completes it. We need to update the customer
        # record with the new status.
        StripeService.update_status(event.data['customer'], 'open')
      when 'invoice.paid'
        # Sent when the customer pays their monthly bill, we
        # need to update the status to the latest so we keep
        # our own record to avoid rate limiting.
        StripeService.update_status(event.data['customer'], 'valid')
      when 'invoice.payment_failed'
        # Sent when the customer failed to pay their monthly
        # bill. We update the status in the database.
        StripeService.update_status(event.data['customer'], 'invalid')
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
