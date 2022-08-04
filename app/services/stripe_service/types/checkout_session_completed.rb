# frozen_string_literal: true

module StripeService
  module Types
    class CheckoutSessionCompleted < Base
      def handle
        update_billing_status(::Billing::OPEN)

        refresh_customer_payment_information!
        unlock_recordings!
      end
    end
  end
end
